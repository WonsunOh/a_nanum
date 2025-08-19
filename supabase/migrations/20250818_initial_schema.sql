-- 1. 사용자 정의 타입 생성
-- =================================================================
CREATE TYPE public.group_buy_status AS ENUM (
  'recruiting', -- 모집 중
  'success',    -- 성공
  'failed',     -- 실패
  'preparing',  -- 상품 준비 중
  'shipped',    -- 배송 중
  'completed'   -- 배송 완료
);


-- 2. 테이블 생성 (순서 매우 중요)
-- =================================================================

-- auth.users를 참조하므로 가장 먼저 생성
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  username TEXT NOT NULL,
  avatar_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 다른 테이블에 의존하지 않으므로 먼저 생성
CREATE TABLE IF NOT EXISTS public.products (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  name TEXT NOT NULL,
  description TEXT,
  image_url TEXT,
  total_price INT NOT NULL,
  source_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- profiles와 products를 참조하므로 그 다음에 생성
CREATE TABLE IF NOT EXISTS public.group_buys (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  host_id UUID NOT NULL REFERENCES public.profiles(id),
  product_id BIGINT NOT NULL REFERENCES public.products(id),
  target_participants INT NOT NULL,
  current_participants INT NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'recruiting',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL
);

-- group_buys와 profiles를 참조하므로 마지막에 생성
CREATE TABLE IF NOT EXISTS public.participants (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  group_buy_id BIGINT NOT NULL REFERENCES public.group_buys(id),
  user_id UUID NOT NULL REFERENCES public.profiles(id),
  delivery_address TEXT NOT NULL,
  payment_status TEXT NOT NULL DEFAULT 'pending',
  tracking_number TEXT,
  quantity INT NOT NULL DEFAULT 1,
  joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(group_buy_id, user_id)
);


-- 2. 데이터베이스 함수 및 트리거 생성
-- =================================================================

-- 회원가입 시 profiles 테이블에 자동 삽입하는 함수
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, username)
  VALUES (new.id, new.email);
  RETURN new;
END;
$$;

-- auth.users 테이블에 INSERT 발생 후 함수를 실행하는 트리거
CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();


-- 공동구매 참여 시 participants 추가 및 group_buys 수량 업데이트 함수
CREATE OR REPLACE FUNCTION public.handle_join_group_buy (
  p_group_buy_id BIGINT, 
  p_user_id UUID,
  p_quantity INT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  INSERT INTO public.participants(group_buy_id, user_id, delivery_address, quantity)
  VALUES (p_group_buy_id, p_user_id, '기본 배송지', p_quantity);

  UPDATE public.group_buys
  SET current_participants = current_participants + p_quantity
  WHERE id = p_group_buy_id;
  -- 💡 참여가 완료된 후, 포인트 지급 함수를 호출합니다.
  perform award_points(p_user_id, 'JOIN_GROUP_BUY');
END;
$$;


-- 3. 스토리지 정책 (RLS for Storage)
-- =================================================================

-- 'products' 버킷에 대한 정책
CREATE POLICY "누구나 이미지를 볼 수 있음"
ON storage.objects FOR SELECT
TO anon, authenticated
USING (bucket_id = 'products');

CREATE POLICY "로그인한 사용자는 이미지 업로드 가능"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'products');


-- 4. 테이블 RLS 정책 (RLS for Tables)
-- =================================================================

-- products 테이블 읽기 정책
CREATE POLICY "사용자는 모든 상품 정보를 볼 수 있습니다"
ON public.products FOR SELECT
TO authenticated
USING (true);

-- group_buys 테이블 읽기 정책
CREATE POLICY "사용자는 모든 공동구매 목록을 볼 수 있습니다"
ON public.group_buys FOR SELECT
TO authenticated
USING (true);

-- group_buys 테이블 수정/삭제 정책
CREATE POLICY "공구 개설자만 수정할 수 있습니다"
ON public.group_buys FOR UPDATE
USING (auth.uid() = host_id);

CREATE POLICY "공구 개설자만 삭제할 수 있습니다"
ON public.group_buys FOR DELETE
USING (auth.uid() = host_id);


-- 5. 공구참여 취소하거나 공구 수량을 변경하는 함수
-- =================================================================

-- 참여 취소 함수
-- 이 함수는 사용자가 참여를 취소할 때 호출됩니다.
create or replace function handle_cancel_participation(p_group_buy_id bigint, p_user_id uuid)
returns void
language plpgsql
security definer
as $$
declare
  -- 취소할 수량을 저장할 변수
  canceled_quantity int;
begin
  -- 1. participants 테이블에서 취소할 주문의 수량을 먼저 조회합니다.
  select quantity into canceled_quantity from public.participants
  where group_buy_id = p_group_buy_id and user_id = p_user_id;

  -- 2. participants 테이블에서 해당 주문을 삭제합니다.
  delete from public.participants
  where group_buy_id = p_group_buy_id and user_id = p_user_id;

  -- 3. group_buys 테이블의 현재 모집 수량을 조회했던 수량만큼 감소시킵니다.
  update public.group_buys
  set current_participants = current_participants - canceled_quantity
  where id = p_group_buy_id;
end;
$$;


-- 수량 변경 함수
-- 이 함수는 사용자가 주문 수량을 변경할 때 호출됩니다.
create or replace function handle_edit_quantity(p_group_buy_id bigint, p_user_id uuid, p_new_quantity int)
returns void
language plpgsql
security definer
as $$
declare
  -- 기존 수량을 저장할 변수
  old_quantity int;
  -- 수량 차이를 저장할 변수
  quantity_diff int;
begin
  -- 1. participants 테이블에서 기존 주문 수량을 조회합니다.
  select quantity into old_quantity from public.participants
  where group_buy_id = p_group_buy_id and user_id = p_user_id;

  -- 2. 수량 차이를 계산합니다. (예: 3개 -> 5개로 변경 시 diff = 2)
  quantity_diff := p_new_quantity - old_quantity;

  -- 3. participants 테이블의 수량을 새로운 수량으로 업데이트합니다.
  update public.participants
  set quantity = p_new_quantity
  where group_buy_id = p_group_buy_id and user_id = p_user_id;

  -- 4. group_buys 테이블의 현재 모집 수량을 수량 차이만큼 증감시킵니다.
  update public.group_buys
  set current_participants = current_participants + quantity_diff
  where id = p_group_buy_id;
end;
$$;
