-- products 테이블에 is_sold_out 컬럼을 추가합니다.
-- BOOLEAN 타입이며, 기본값은 false (품절 아님)로 설정합니다.
ALTER TABLE public.products
ADD COLUMN is_sold_out BOOLEAN NOT NULL DEFAULT false;