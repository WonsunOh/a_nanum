-- supabase/migrations/0036_add_order_type.sql

-- 주문 타입을 구분하기 위한 ENUM 타입 생성
CREATE TYPE public.order_type AS ENUM ('shop', 'group_buy');

-- orders 테이블에 order_type 컬럼 추가
ALTER TABLE public.orders
ADD COLUMN order_type public.order_type NOT NULL DEFAULT 'group_buy';

-- 기존 데이터는 모두 'group_buy'였으므로, 기본값을 설정해줍니다.
-- 앞으로 쇼핑몰 주문이 생길 때는 'shop'으로 값을 넣어주어야 합니다.