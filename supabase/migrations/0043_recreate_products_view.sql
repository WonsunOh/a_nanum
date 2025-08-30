-- supabase/migrations/0043_recreate_products_view.sql

-- 기존 뷰를 삭제합니다.
DROP VIEW IF EXISTS public.products_with_category_path;

-- discount_price 등 모든 최신 컬럼을 포함하여 뷰를 다시 생성합니다.
CREATE OR REPLACE VIEW public.products_with_category_path AS
SELECT
  p.*,  -- 이제 p.*는 discount_price 컬럼까지 모두 포함하게 됩니다.
  public.get_category_path(p.category_id) AS category_path
FROM
  public.products p;