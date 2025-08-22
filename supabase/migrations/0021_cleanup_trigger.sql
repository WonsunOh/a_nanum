-- 1. 이전에 만들었던 트리거를 삭제합니다.
DROP TRIGGER IF EXISTS on_group_buy_status_change ON public.group_buys;

-- 2. 이전에 만들었던 중간 다리 함수를 삭제합니다.
DROP FUNCTION IF EXISTS public.handle_status_change_notification();