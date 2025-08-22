-- 'update-deal-statuses'라는 이름으로 새로운 Cron Job을 등록합니다.
-- '0 0 * * *' : 매일 0시 0분 (자정)을 의미하는 Cron 표현식입니다.
-- 'SELECT public.update_group_buy_statuses();' : 실행할 함수입니다.
SELECT cron.schedule(
  'update-deal-statuses',
  '0 0 * * *',
  'SELECT public.update_group_buy_statuses()'
);