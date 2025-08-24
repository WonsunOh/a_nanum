-- products 테이블에 상품 코드와 연관 상품 코드 컬럼을 추가합니다.
ALTER TABLE public.products
ADD COLUMN product_code TEXT,
ADD COLUMN related_product_code TEXT;

-- 상품 코드는 고유해야 하므로 UNIQUE 제약 조건을 추가합니다.
ALTER TABLE public.products
ADD CONSTRAINT products_product_code_key UNIQUE (product_code);