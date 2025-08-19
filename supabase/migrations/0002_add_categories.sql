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