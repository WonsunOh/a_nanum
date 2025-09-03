-- 🚀 완전히 정리된 결제 시스템 SQL
-- payments 테이블 없이 participants 테이블만 사용

-- 1. participants 테이블에 결제 관련 컬럼 추가
ALTER TABLE public.participants
ADD COLUMN IF NOT EXISTS merchant_uid TEXT UNIQUE,     -- 가맹점 주문번호
ADD COLUMN IF NOT EXISTS imp_uid TEXT UNIQUE,          -- 포트원 거래번호
ADD COLUMN IF NOT EXISTS payment_amount INT,           -- 결제 금액
ADD COLUMN IF NOT EXISTS payment_method TEXT,          -- 결제 수단
ADD COLUMN IF NOT EXISTS paid_at TIMESTAMPTZ;          -- 결제 완료 시간

-- 2. 성능을 위한 인덱스 추가
CREATE INDEX IF NOT EXISTS idx_participants_merchant_uid ON public.participants(merchant_uid);
CREATE INDEX IF NOT EXISTS idx_participants_payment_status ON public.participants(payment_status);
CREATE INDEX IF NOT EXISTS idx_participants_user_payment ON public.participants(user_id, payment_status);

-- 3. 결제 성공 처리 함수
CREATE OR REPLACE FUNCTION public.handle_payment_success(
  p_merchant_uid TEXT,
  p_imp_uid TEXT,
  p_amount INT,
  p_payment_method TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_group_buy_id BIGINT;
BEGIN
  -- participants 테이블의 결제 정보 업데이트
  UPDATE public.participants 
  SET 
    imp_uid = p_imp_uid,
    payment_status = 'paid',
    payment_method = p_payment_method,
    payment_amount = p_amount,
    paid_at = NOW()
  WHERE merchant_uid = p_merchant_uid
  RETURNING group_buy_id INTO v_group_buy_id;

  -- 공동구매 상태 확인 및 업데이트 (목표 달성 시)
  UPDATE public.group_buys 
  SET status = 'in_progress'
  WHERE id = v_group_buy_id 
    AND current_participants >= target_participants
    AND status = 'recruiting';
END;
$$;

-- 4. 결제 취소 처리 함수
CREATE OR REPLACE FUNCTION public.handle_payment_cancel(
  p_merchant_uid TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- participants 테이블의 결제 상태를 취소로 변경
  UPDATE public.participants 
  SET payment_status = 'cancelled'
  WHERE merchant_uid = p_merchant_uid;
END;
$$;

-- 5. 공동구매 참여 + 결제 준비를 동시에 처리하는 함수
CREATE OR REPLACE FUNCTION public.handle_join_group_buy_with_payment(
  p_group_buy_id BIGINT, 
  p_user_id UUID,
  p_quantity INT,
  p_merchant_uid TEXT,
  p_payment_amount INT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- participants 테이블에 참여 정보 + 결제 정보를 한 번에 삽입
  INSERT INTO public.participants(
    group_buy_id, 
    user_id, 
    delivery_address, 
    quantity,
    merchant_uid,
    payment_amount,
    payment_status
  )
  VALUES (
    p_group_buy_id, 
    p_user_id, 
    '기본 배송지', 
    p_quantity,
    p_merchant_uid,
    p_payment_amount,
    'pending'
  );

  -- group_buys 테이블의 현재 참여 수량 업데이트
  UPDATE public.group_buys
  SET current_participants = current_participants + p_quantity
  WHERE id = p_group_buy_id;
  
  -- 포인트 지급
  PERFORM award_points(p_user_id, 'JOIN_GROUP_BUY');
END;
$$;