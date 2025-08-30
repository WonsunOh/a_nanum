-- supabase/migrations/0039_grant_execute_on_function.sql (새 파일)

GRANT EXECUTE
ON FUNCTION public.get_category_path(p_category_id bigint)
TO authenticated, anon;