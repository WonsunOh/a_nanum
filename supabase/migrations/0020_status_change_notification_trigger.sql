-- 상태 변경 시 Edge Function을 호출하는 함수 (Vault 사용 버전)
create or replace function public.handle_status_change_notification()
returns trigger
language plpgsql
security definer -- 이 함수는 생성자의 권한(보통 슈퍼유저)으로 실행됩니다.
as $$
declare
  service_key text;
begin
  -- 1. Vault에서 'supabase_service_key'라는 이름의 비밀 키를 안전하게 가져옵니다.
  select decrypted_secret into service_key from supabase_vault.secrets where name = 'supabase_service_key';

  -- 2. 가져온 키를 사용하여 Authorization 헤더를 동적으로 만듭니다.
  perform net.http_post(
    url:='https://oyoznvosuyxhgxmbfaow.supabase.co.supabase.co/functions/v1/send-notification',
    headers:=jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || service_key -- 💡 Vault에서 가져온 키 사용
    ),
    body:=jsonb_build_object('group_buy_id', new.id, 'new_status', new.status)
  );
  return new;
end;
$$;