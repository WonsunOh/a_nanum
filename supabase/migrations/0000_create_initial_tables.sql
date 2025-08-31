-- pg_cron 확장 기능 활성화
CREATE EXTENSION IF NOT EXISTS pg_cron WITH SCHEMA extensions;



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



-- 1. 카테고리 정보를 저장할 새로운 테이블 생성
CREATE TABLE IF NOT EXISTS public.categories (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  name TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. products 테이블에 새로운 컬럼들 추가
ALTER TABLE public.products
ADD COLUMN IF NOT EXISTS category_id BIGINT REFERENCES public.categories(id),
ADD COLUMN IF NOT EXISTS external_product_id TEXT;

-- (선택 사항) 테스트용 카테고리 데이터 삽입
INSERT INTO public.categories (name) 
VALUES ('가공식품'), ('생활용품'), ('신선식품')
ON CONFLICT (name) DO NOTHING;

-- categories 테이블에 parent_id 컬럼을 추가합니다.
-- 이 컬럼은 같은 테이블의 id를 참조하는 '자기 참조' 관계입니다.
ALTER TABLE public.categories
ADD COLUMN IF NOT EXISTS parent_id BIGINT REFERENCES public.categories(id);


-- public 스키마의 products 테이블에
-- created_at 이라는 이름의 컬럼을 추가합니다.
-- 이 컬럼이 이미 존재할 경우 에러가 발생하지 않도록 IF NOT EXISTS를 추가합니다.
ALTER TABLE public.products
ADD COLUMN IF NOT EXISTS created_at TIMESTAMTz NOT NULL DEFAULT NOW();

-- public 스키마의 profiles 테이블에
-- phone 이라는 이름의 컬럼을 추가합니다.
-- TEXT 타입으로 만들어 다양한 형식(예: 010-1234-5678)을 저장할 수 있게 합니다.
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS phone TEXT;

-- 1. 송장 번호 업데이트를 위한 사용자 정의 데이터 타입을 생성합니다.
-- tracking_update 타입이 존재하지 않을 경우에만 생성합니다.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'tracking_update') THEN
        CREATE TYPE public.tracking_update AS (
            p_id BIGINT,
            t_num TEXT
        );
    END IF;
END$$;

-- 2. 위에서 만든 타입의 배열을 받아, 여러 주문을 한번에 업데이트하는 함수를 생성합니다.
CREATE OR REPLACE FUNCTION public.batch_update_tracking_numbers(updates tracking_update[])
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
  -- 배열을 순회하기 위한 변수
  upd tracking_update;
BEGIN
  -- 전달받은 배열(updates)을 순회하면서 각 항목을 처리합니다.
  FOREACH upd IN ARRAY updates
  LOOP
    -- participants 테이블에서 id가 일치하는 주문을 찾아 송장번호를 업데이트합니다.
    UPDATE public.participants
    SET tracking_number = upd.t_num
    WHERE id = upd.p_id;

    -- TODO: 여기에 사용자에게 '배송 시작' 알림을 보내는 로직 추가 가능
  END LOOP;
END;
$$;


create or replace function get_dashboard_metrics()
returns table (
  total_users bigint,
  total_sales bigint,
  active_deals bigint,
  successful_deals bigint
)
language sql
as $$
  select
    -- 총 회원 수 (profiles 테이블 기준)
    (select count(*) from public.profiles) as total_users,
    -- 총 매출 (모집 성공한 공구의 총액 합산)
    (select sum(p.total_price)
     from public.group_buys gb
     join public.products p on gb.product_id = p.id
     where gb.status = 'success') as total_sales,
    -- 현재 모집 중인 공구 수
    (select count(*) from public.group_buys where status = 'recruiting') as active_deals,
    -- 모집 성공한 공구 수
    (select count(*) from public.group_buys where status = 'success') as successful_deals;
$$;


-- 1. 고객 문의를 저장할 테이블 생성
CREATE TABLE IF NOT EXISTS public.inquiries (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  author_id UUID NOT NULL REFERENCES public.profiles(id),
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending', -- pending(답변 대기), answered(답변 완료)
  reply TEXT, -- 관리자의 답변
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  answered_at TIMESTAMPTZ
);



-- 특정 사용자의 상세 정보와 전체 참여(주문) 목록을 반환하는 함수
create or replace function get_user_details(p_user_id uuid)
returns json
language sql
as $$
  select
    json_build_object(
      'profile', (select to_json(p) from profiles p where id = p_user_id),
      'participations', (
        select json_agg(
          json_build_object(
            'quantity', pt.quantity,
            'joined_at', pt.joined_at,
            'group_buy_status', gb.status,
            'product_name', pr.name,
            'product_image_url', pr.image_url
          )
        )
        from participants pt
        join group_buys gb on pt.group_buy_id = gb.id
        join products pr on gb.product_id = pr.id
        where pt.user_id = p_user_id
      )
    )
$$;


-- 답변 템플릿을 저장할 테이블
CREATE TABLE IF NOT EXISTS public.reply_templates (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  title TEXT NOT NULL UNIQUE, -- 템플릿 제목 (예: "배송 지연 안내")
  content TEXT NOT NULL, -- 템플릿 내용
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 관리자만 접근 가능하도록 RLS 정책을 추가할 수 있으나, 
-- service_role_key를 사용하므로 우선은 생략합니다.


-- 1. profiles 테이블에 'level' 컬럼 추가
-- level: 1(일반), 5(우수), 10(공구장) 등으로 규칙을 정합니다. 기본값은 1입니다.
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS level INT NOT NULL DEFAULT 1;


-- 2. 사용자들이 공구 개설을 '신청'하는 게시판 테이블 생성
CREATE TABLE IF NOT EXISTS public.proposals (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  proposer_id UUID NOT NULL REFERENCES public.profiles(id),
  product_name TEXT NOT NULL,
  product_url TEXT, -- 참고할 상품 링크
  reason TEXT, -- 신청 이유
  status TEXT NOT NULL DEFAULT 'pending', -- pending(검토중), approved(승인), rejected(반려)
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);



-- profiles 테이블에 'points' 컬럼 추가
-- 사용자가 활동할 때마다 이 점수가 누적됩니다. 기본값은 0입니다.
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS points INT NOT NULL DEFAULT 0;


-- 포인트 부여 및 레벨업 처리를 위한 함수
create or replace function award_points(p_user_id uuid, p_action text)
returns void
language plpgsql
security definer
as $$
declare
  points_to_award int;
  new_total_points int;
  new_level int;
begin
  -- 1. 행동(p_action) 타입에 따라 지급할 포인트를 결정합니다.
  case p_action
    when 'CREATE_GROUP_BUY' then points_to_award := 20; -- 공구 개설 시 20 포인트
    when 'JOIN_GROUP_BUY' then points_to_award := 10;   -- 공구 참여 시 10 포인트
    -- TODO: 'SUCCESS_HOST' (공구 성공시킨 공구장), 'FIRST_REPLY' 등 다양한 조건 추가 가능
    else points_to_award := 0;
  end case;

  -- 2. profiles 테이블의 기존 포인트에 새로운 포인트를 더하고, 그 결과를 new_total_points 변수에 저장합니다.
  update public.profiles
  set points = points + points_to_award
  where id = p_user_id
  returning points into new_total_points;

  -- 3. 새로 계산된 총 포인트를 기준으로 레벨업 조건을 확인합니다.
  select level into new_level from public.profiles where id = p_user_id;

  -- 예시 레벨업 규칙 (이 부분을 자유롭게 수정하세요)
  if new_total_points >= 1000 and new_level < 10 then
    new_level := 10; -- 1000점 이상이면 '공구장' 레벨
  elsif new_total_points >= 500 and new_level < 5 then
    new_level := 5; -- 500점 이상이면 '우수회원' 레벨
  elsif new_total_points >= 100 and new_level < 2 then
    new_level := 2; -- 100점 이상이면 '일반회원' 레벨
  end if;

  -- 4. 변경된 레벨을 profiles 테이블에 업데이트합니다.
  update public.profiles
  set level = new_level
  where id = p_user_id;

end;
$$;


create or replace function handle_create_group_buy_from_master(
  p_product_id bigint,
  p_target_participants int,
  p_initial_quantity int,
  p_deadline date
)
returns void
language plpgsql
as $$
declare
  new_group_buy_id bigint;
begin
  insert into public.group_buys(
    host_id, 
    product_id, 
    target_participants, 
    current_participants, 
    deadline, 
    expires_at -- 💡 expires_at 컬럼 추가
  )
  values (
    auth.uid(), 
    p_product_id, 
    p_target_participants, 
    p_initial_quantity, 
    p_deadline,
    (p_deadline + interval '1 day')::timestamptz - interval '1 second' -- 💡 마감일 자정 직전으로 설정
  )
  returning id into new_group_buy_id;

  -- 개설자를 첫 번째 참여자로 participants 테이블에 추가
  insert into public.participants(group_buy_id, user_id, delivery_address, quantity)
  values (new_group_buy_id, auth.uid(), '기본 배송지', p_initial_quantity);

  -- 포인트 지급 함수 호출
  perform award_points(auth.uid(), 'CREATE_GROUP_BUY');
end;
$$;


-- 공구 개설과 포인트 지급을 한번에 처리하는 함수
create or replace function handle_create_group_buy(
  p_name text,
  p_total_price int,
  p_target_participants int,
  p_image_url text,
  p_description text,
  p_category_id bigint,
  p_external_product_id text
)
returns void
language plpgsql
as $$
declare
  new_product_id bigint;
begin
  -- 1. 먼저 products 테이블에 새 상품을 등록하고, 새로 생성된 id를 new_product_id 변수에 저장합니다.
  insert into public.products(name, total_price, image_url, description, category_id, external_product_id)
  values (p_name, p_total_price, p_image_url, p_description, p_category_id, p_external_product_id)
  returning id into new_product_id;

  -- 2. 위에서 받은 new_product_id를 사용하여 group_buys 테이블에 공구를 개설합니다.
  insert into public.group_buys(host_id, product_id, target_participants, expires_at)
  values (auth.uid(), new_product_id, p_target_participants, now() + interval '3 days');

  -- 3. 공구 개설이 완료된 후, 포인트 지급 함수를 호출합니다.
  perform award_points(auth.uid(), 'CREATE_GROUP_BUY');
end;
$$;


-- 만약을 위해 기존 제약조건을 먼저 삭제합니다.
-- 이렇게 하면 이 스크립트를 여러 번 실행해도 안전합니다.
ALTER TABLE public.group_buys DROP CONSTRAINT IF EXISTS group_buys_product_id_fkey;


-- group_buys 테이블과 products 테이블 사이에
-- 'group_buys_product_id_fkey'라는 이름의 외래 키 제약 조건을 추가합니다.
-- 이 코드는 group_buys.product_id가 products.id를 참조하도록 합니다.
ALTER TABLE public.group_buys
ADD CONSTRAINT group_buys_product_id_fkey
FOREIGN KEY (product_id) REFERENCES public.products(id)
ON DELETE CASCADE; -- 💡 상품 마스터가 삭제되면 관련된 공구도 함께 삭제되도록 설정


-- group_buys와 products 테이블을 JOIN한 결과를 보여주는 '뷰' 생성
CREATE OR REPLACE VIEW public.group_buys_with_products AS
SELECT
  gb.*, -- group_buys 테이블의 모든 컬럼
  p.name AS product_name,
  p.description AS product_description,
  p.image_url AS product_image_url,
  p.total_price AS product_total_price
FROM
  public.group_buys gb
JOIN
  public.products p ON gb.product_id = p.id;


  -- group_buys 테이블에 마감일을 저장할 'deadline' 컬럼 추가
ALTER TABLE public.group_buys
ADD COLUMN IF NOT EXISTS deadline DATE;


create or replace function update_group_buy_statuses()
returns void
language plpgsql
as $$
begin
  -- 1. 목표 수량에 도달한 공구를 'success'로 변경
  update public.group_buys
  set status = 'success'
  where status = 'recruiting' and current_participants >= target_participants;

  -- 2. 마감일이 지났지만 목표 수량에 도달하지 못한 공구를 'failed'로 변경
  update public.group_buys
  set status = 'failed'
  where status = 'recruiting' and deadline < current_date;
end;
$$;


-- 'update-deal-statuses'라는 이름으로 새로운 Cron Job을 등록합니다.
-- '0 0 * * *' : 매일 0시 0분 (자정)을 의미하는 Cron 표현식입니다.
-- 'SELECT public.update_group_buy_statuses();' : 실행할 함수입니다.
SELECT cron.schedule(
  'update-deal-statuses',
  '0 0 * * *',
  'SELECT public.update_group_buy_statuses()'
);


ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS fcm_token TEXT;


-- 상태 변경 시 Edge Function을 호출하는 함수 (Vault 사용 버전)
create or replace function public.handle_status_change_notification()
returns trigger
language plpgsql
security definer -- 이 함수는 생성자의 권한(보통 슈퍼유저)으로 실행됩니다.
as $$
declare
  service_key text;
begin
  -- 1. Vault에서 'supabase_service_key'라는 이름의 비밀 키를 안전하게 가져옵니다.
  select decrypted_secret into service_key from supabase_vault.secrets where name = 'supabase_service_key';

  -- 2. 가져온 키를 사용하여 Authorization 헤더를 동적으로 만듭니다.
  perform net.http_post(
    url:='https://oyoznvosuyxhgxmbfaow.supabase.co.supabase.co/functions/v1/send-notification',
    headers:=jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || service_key -- 💡 Vault에서 가져온 키 사용
    ),
    body:=jsonb_build_object('group_buy_id', new.id, 'new_status', new.status)
  );
  return new;
end;
$$;


-- 1. 이전에 만들었던 트리거를 삭제합니다.
DROP TRIGGER IF EXISTS on_group_buy_status_change ON public.group_buys;

-- 2. 이전에 만들었던 중간 다리 함수를 삭제합니다.
DROP FUNCTION IF EXISTS public.handle_status_change_notification();





-- RLS(행 수준 보안)를 활성화합니다.
ALTER TABLE public.cart_items ENABLE ROW LEVEL SECURITY;



-- RLS(행 수준 보안) 활성화
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;




-- 기존의 handle_new_user 함수를 새로운 버전으로 교체합니다.
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- auth.users 테이블에서 받은 raw_user_meta_data를 사용하여 profiles 테이블에 데이터를 삽입합니다.
  INSERT INTO public.profiles (id, full_name, nickname)
  VALUES (
    new.id,
    new.raw_user_meta_data ->> 'full_name',
    new.raw_user_meta_data ->> 'nickname'
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 트리거가 이 함수를 사용하도록 다시 설정합니다. (필수는 아니지만 명확성을 위해)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();



-- RLS(행 수준 보안)를 활성화합니다.
ALTER TABLE public.wishlist_items ENABLE ROW LEVEL SECURITY;




-- 1. 기존 옵션 관련 테이블들을 삭제합니다. (데이터가 있다면 백업 후 진행하세요)
DROP TABLE IF EXISTS public.product_option_items;
DROP TABLE IF EXISTS public.product_options;




-- RLS 정책을 새로 설정합니다. (기존 정책은 테이블 삭제 시 함께 사라졌습니다)
ALTER TABLE public.product_option_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_option_values ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_variants ENABLE ROW LEVEL SECURITY;



-- 2. 테이블 및 컬럼에 대한 설명 추가 (주석)
COMMENT ON TABLE public.settings IS '쇼핑몰의 각종 설정을 저장하는 키-값 테이블';
COMMENT ON COLUMN public.settings.key IS '설정 항목의 고유 키 (예: shipping_fee)';
COMMENT ON COLUMN public.settings.value IS '설정 값';
COMMENT ON COLUMN public.settings.comment IS '해당 설정에 대한 설명';

-- 3. Row Level Security (RLS) 활성화
ALTER TABLE public.settings ENABLE ROW LEVEL SECURITY;


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
