-- supabase/migrations/0037_create_get_category_path_function.sql (전체 교체)

CREATE OR REPLACE FUNCTION public.get_category_path(p_category_id bigint)
RETURNS text
LANGUAGE sql
STABLE
AS $$
  -- ⭐️ WITH 구문을 SELECT 안으로 이동하여 문법 오류를 해결합니다.
  SELECT (
    WITH RECURSIVE category_path AS (
      -- 1. 시작점: 주어진 ID의 카테고리에서 시작
      SELECT id, name, parent_id, 1 as depth
      FROM public.categories
      WHERE id = p_category_id

      UNION ALL

      -- 2. 재귀: 부모 카테고리를 찾아 위로 올라감
      SELECT c.id, c.name, c.parent_id, cp.depth + 1
      FROM public.categories c
      JOIN category_path cp ON cp.parent_id = c.id
    )
    -- 3. 결과: 찾은 모든 카테고리 이름을 ' > '로 연결하여 반환
    SELECT string_agg(name, ' > ' ORDER BY depth DESC)
    FROM category_path
  )
$$;