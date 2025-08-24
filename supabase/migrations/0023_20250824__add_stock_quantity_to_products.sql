-- a_nanum/supabase/migrations/YYYYMMDDHHMMSS_add_stock_quantity_to_products.sql

-- products 테이블에 stock_quantity 컬럼을 추가합니다.
-- 타입은 정수(INTEGER)이고, 기본값(DEFAULT)은 0으로 설정합니다.
ALTER TABLE public.products
ADD COLUMN stock_quantity INTEGER NOT NULL DEFAULT 0;