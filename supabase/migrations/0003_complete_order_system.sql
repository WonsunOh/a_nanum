-- supabase/migrations/0003_complete_order_system.sql
-- 주문 시스템 및 부분 취소 기능 통합 구현

-- 1. orders 테이블 status 제약조건 업데이트
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_status_check;
ALTER TABLE orders ADD CONSTRAINT orders_status_check 
  CHECK (status IN ('pending', 'confirmed', 'cancel_requested', 'cancelled', 'preparing', 'shipped', 'delivered', 'refunded'));

-- 2. orders 테이블에 부분 취소 관련 컬럼 추가
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS cancelled_amount INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS refunded_amount INTEGER DEFAULT 0;

-- 3. order_items 테이블에 status 컬럼 추가
ALTER TABLE order_items 
ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'active' 
CHECK (status IN ('active', 'cancel_requested', 'cancelled', 'shipped', 'delivered'));

-- 4. 주문 취소 요청 테이블 생성 (전체 주문 취소용)
CREATE TABLE IF NOT EXISTS order_cancellations (
  id BIGSERIAL PRIMARY KEY,
  order_id BIGINT REFERENCES orders(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  cancel_reason TEXT NOT NULL,
  cancel_detail TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  admin_id UUID REFERENCES auth.users(id),
  admin_note TEXT,
  processed_at TIMESTAMP WITH TIME ZONE,
  requested_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. 개별 아이템 취소 요청 테이블 생성 (부분 취소용)
CREATE TABLE IF NOT EXISTS order_item_cancellations (
  id BIGSERIAL PRIMARY KEY,
  order_item_id BIGINT REFERENCES order_items(id) ON DELETE CASCADE,
  order_id BIGINT REFERENCES orders(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  cancel_reason TEXT NOT NULL,
  cancel_detail TEXT,
  cancel_quantity INTEGER NOT NULL DEFAULT 1,
  refund_amount INTEGER NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  admin_id UUID REFERENCES auth.users(id),
  admin_note TEXT,
  processed_at TIMESTAMP WITH TIME ZONE,
  requested_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. RLS 정책 설정
ALTER TABLE order_cancellations ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_item_cancellations ENABLE ROW LEVEL SECURITY;

-- order_cancellations 정책
CREATE POLICY "order_cancellations_select_policy" ON order_cancellations
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "order_cancellations_insert_policy" ON order_cancellations
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- order_item_cancellations 정책
CREATE POLICY "order_item_cancellations_select_policy" ON order_item_cancellations
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "order_item_cancellations_insert_policy" ON order_item_cancellations
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 7. 전체 주문 취소 요청 함수
CREATE OR REPLACE FUNCTION request_order_cancellation(
  p_order_id BIGINT,
  p_user_id UUID,
  p_cancel_reason TEXT,
  p_cancel_detail TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_order_status TEXT;
  v_cancellation_id BIGINT;
  v_result JSON;
BEGIN
  -- 사용자 인증 확인
  IF auth.uid() != p_user_id THEN
    RAISE EXCEPTION 'Unauthorized: User ID mismatch';
  END IF;

  -- 주문 존재 및 소유권 확인
  SELECT status INTO v_order_status
  FROM orders
  WHERE id = p_order_id AND user_id = p_user_id;

  IF v_order_status IS NULL THEN
    RAISE EXCEPTION 'Order not found or access denied';
  END IF;

  -- 취소 가능한 상태 확인
  IF v_order_status NOT IN ('pending', 'confirmed', 'preparing') THEN
    RAISE EXCEPTION 'Order cannot be cancelled in current status: %', v_order_status;
  END IF;

  -- 취소 요청 생성
  INSERT INTO order_cancellations (
    order_id, user_id, cancel_reason, cancel_detail, status
  ) VALUES (
    p_order_id, p_user_id, p_cancel_reason, p_cancel_detail, 'pending'
  ) RETURNING id INTO v_cancellation_id;

  -- 주문 상태 업데이트
  UPDATE orders 
  SET status = 'cancel_requested' 
  WHERE id = p_order_id;

  SELECT json_build_object(
    'cancellation_id', v_cancellation_id,
    'order_id', p_order_id,
    'status', 'pending'
  ) INTO v_result;

  RETURN v_result;
EXCEPTION
  WHEN OTHERS THEN
    RAISE EXCEPTION 'Cancellation request failed: %', SQLERRM;
END;
$$;

-- 8. 부분 취소 요청 함수
CREATE OR REPLACE FUNCTION request_partial_order_cancellation(
  p_order_item_id BIGINT,
  p_cancel_reason TEXT,
  p_cancel_detail TEXT DEFAULT NULL,
  p_cancel_quantity INTEGER DEFAULT 1
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_order_item RECORD;
  v_cancellation_id BIGINT;
  v_refund_amount INTEGER;
  v_result JSON;
BEGIN
  -- 주문 아이템 정보 조회
  SELECT oi.*, o.status as order_status, o.user_id 
  INTO v_order_item
  FROM order_items oi
  JOIN orders o ON oi.order_id = o.id
  WHERE oi.id = p_order_item_id;

  -- 아이템 존재 확인
  IF v_order_item.id IS NULL THEN
    RAISE EXCEPTION 'Order item not found';
  END IF;

  -- 사용자 권한 확인
  IF auth.uid() != v_order_item.user_id THEN
    RAISE EXCEPTION 'Unauthorized: Access denied';
  END IF;

  -- 취소 가능한 상태 확인
  IF v_order_item.order_status NOT IN ('confirmed', 'preparing') THEN
    RAISE EXCEPTION 'Order cannot be cancelled in current status: %', v_order_item.order_status;
  END IF;

  -- 아이템 상태 확인
  IF v_order_item.status != 'active' THEN
    RAISE EXCEPTION 'This item cannot be cancelled (current status: %)', v_order_item.status;
  END IF;

  -- 취소 수량 검증
  IF p_cancel_quantity <= 0 OR p_cancel_quantity > v_order_item.quantity THEN
    RAISE EXCEPTION 'Invalid cancel quantity: %', p_cancel_quantity;
  END IF;

  -- 환불 금액 계산
  v_refund_amount := v_order_item.price_per_item * p_cancel_quantity;

  -- 부분 취소 요청 생성
  INSERT INTO order_item_cancellations (
    order_item_id, order_id, user_id, cancel_reason, cancel_detail,
    cancel_quantity, refund_amount, status
  ) VALUES (
    p_order_item_id, v_order_item.order_id, v_order_item.user_id,
    p_cancel_reason, p_cancel_detail, p_cancel_quantity, v_refund_amount, 'pending'
  ) RETURNING id INTO v_cancellation_id;

  -- 아이템 상태 업데이트
  UPDATE order_items 
  SET status = 'cancel_requested' 
  WHERE id = p_order_item_id;

  SELECT json_build_object(
    'cancellation_id', v_cancellation_id,
    'order_item_id', p_order_item_id,
    'order_id', v_order_item.order_id,
    'cancel_quantity', p_cancel_quantity,
    'refund_amount', v_refund_amount,
    'status', 'pending'
  ) INTO v_result;

  RETURN v_result;
EXCEPTION
  WHEN OTHERS THEN
    RAISE EXCEPTION 'Partial cancellation request failed: %', SQLERRM;
END;
$$;

-- 9. 주문 생성 트랜잭션 함수
CREATE OR REPLACE FUNCTION create_order_transaction(
  p_user_id UUID,
  p_total_amount INTEGER,
  p_shipping_fee INTEGER,
  p_recipient_name TEXT,
  p_recipient_phone TEXT,
  p_shipping_address TEXT,
  p_status TEXT DEFAULT 'pending',
  p_cart_items JSONB DEFAULT '[]'::JSONB,
  p_payment_id TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_order_id BIGINT;
  v_item JSONB;
  v_result JSON;
BEGIN
  -- 사용자 인증 확인
  IF auth.uid() != p_user_id THEN
    RAISE EXCEPTION 'Unauthorized: User ID mismatch';
  END IF;

  -- 주문 생성
  INSERT INTO orders (
    user_id, total_amount, shipping_fee, recipient_name, 
    recipient_phone, shipping_address, status
  ) VALUES (
    p_user_id, p_total_amount, p_shipping_fee, p_recipient_name,
    p_recipient_phone, p_shipping_address, p_status
  ) RETURNING id INTO v_order_id;

  -- 주문 아이템 생성
  FOR v_item IN SELECT * FROM jsonb_array_elements(p_cart_items)
  LOOP
    INSERT INTO order_items (order_id, product_id, quantity, price_per_item)
    VALUES (
      v_order_id,
      (v_item->>'product_id')::INTEGER,
      (v_item->>'quantity')::INTEGER,
      (v_item->>'price_per_item')::INTEGER
    );

    -- 장바구니 아이템 삭제 (cart_item_id가 있는 경우)
    IF v_item ? 'cart_item_id' THEN
      DELETE FROM cart_items 
      WHERE id = (v_item->>'cart_item_id')::INTEGER 
      AND user_id = p_user_id;
    END IF;
  END LOOP;

  -- 결제 정보 저장 (있는 경우)
  IF p_payment_id IS NOT NULL THEN
    INSERT INTO payments (
      order_id, user_id, payment_key, amount, status, 
      method, payment_type, approved_at
    ) VALUES (
      v_order_id, p_user_id, p_payment_id, p_total_amount, 'completed',
      'portone', 'payment', NOW()
    ) ON CONFLICT DO NOTHING;
  END IF;

  -- 결과 반환
  SELECT json_build_object(
    'id', v_order_id,
    'user_id', p_user_id,
    'total_amount', p_total_amount,
    'status', p_status,
    'created_at', NOW()
  ) INTO v_result;

  RETURN v_result;
EXCEPTION
  WHEN OTHERS THEN
    RAISE EXCEPTION 'Order creation failed: %', SQLERRM;
END;
$$;

-- 10. 인덱스 추가
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_status ON order_items(status);
CREATE INDEX IF NOT EXISTS idx_order_cancellations_order_id ON order_cancellations(order_id);
CREATE INDEX IF NOT EXISTS idx_order_item_cancellations_order_id ON order_item_cancellations(order_id);
CREATE INDEX IF NOT EXISTS idx_order_item_cancellations_status ON order_item_cancellations(status);