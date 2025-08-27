-- products 테이블에 배송비와 태그 컬럼을 추가합니다.
ALTER TABLE public.products
ADD COLUMN shipping_fee INTEGER NOT NULL DEFAULT 3000, -- 기본 배송비 3000원
ADD COLUMN tags JSONB; -- 히트, 추천 등 다양한 태그를 유연하게 저장하기 위해 JSONB 타입 사용