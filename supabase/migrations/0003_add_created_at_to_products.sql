-- public 스키마의 products 테이블에
-- created_at 이라는 이름의 컬럼을 추가합니다.
-- 이 컬럼이 이미 존재할 경우 에러가 발생하지 않도록 IF NOT EXISTS를 추가합니다.
ALTER TABLE public.products
ADD COLUMN IF NOT EXISTS created_at TIMESTAMTz NOT NULL DEFAULT NOW();