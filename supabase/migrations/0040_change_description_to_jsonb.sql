-- supabase/migrations/0040_change_description_to_jsonb.sql (최종 수정)

-- 1단계: description 컬럼에 의존하는 VIEW들을 먼저 삭제합니다.
-- 공동구매 VIEW는 이제 사용하지 않으므로 삭제만 하고 다시 만들지 않습니다.
DROP VIEW IF EXISTS public.group_buys_with_products;
DROP VIEW IF EXISTS public.products_with_category_path;


-- 2단계: 이제 안전하게 products 테이블의 description 컬럼 타입을 변경합니다.
ALTER TABLE public.products
ALTER COLUMN description TYPE jsonb
USING (
  CASE
    WHEN description IS NULL OR description = '' THEN '[]'::jsonb
    ELSE ('[{"insert":"' || replace(description, '"', '\"') || '\n"}]')::jsonb
  END
);

ALTER TABLE public.products
ALTER COLUMN description SET DEFAULT '[]'::jsonb;


-- 3단계: 쇼핑몰 기능에 필요한 VIEW만 다시 생성합니다.
CREATE OR REPLACE VIEW public.products_with_category_path AS
SELECT
  p.*,
  public.get_category_path(p.category_id) AS category_path
FROM
  public.products p;