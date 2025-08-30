-- supabase/migrations/0038_create_products_view.sql (전체 교체)

CREATE OR REPLACE VIEW public.products_with_category_path AS
SELECT
  p.*,  -- products 테이블의 모든 컬럼
  public.get_category_path(p.category_id) AS category_path
FROM
  public.products p;