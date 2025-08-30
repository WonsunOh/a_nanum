-- supabase/migrations/0041_add_discount_to_products.sql

ALTER TABLE public.products
ADD COLUMN discount_price INTEGER, -- 할인 판매가
ADD COLUMN discount_start_date TIMESTAMPTZ, -- 할인 시작일
ADD COLUMN discount_end_date TIMESTAMPTZ; -- 할인 종료일

COMMENT ON COLUMN public.products.discount_price IS '할인 판매가. NULL이거나 0이면 할인이 아님.';
COMMENT ON COLUMN public.products.discount_start_date IS '할인 기간 시작일';
COMMENT ON COLUMN public.products.discount_end_date IS '할인 기간 종료일';