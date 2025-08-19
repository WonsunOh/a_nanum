create or replace function handle_create_group_buy_from_master(
  p_product_id bigint,
  p_target_participants int
)
returns void
language plpgsql
as $$
begin
  -- 1. 전달받은 product_id를 사용하여 group_buys 테이블에 공구를 개설합니다.
  insert into public.group_buys(host_id, product_id, target_participants, expires_at)
  values (auth.uid(), p_product_id, p_target_participants, now() + interval '3 days');

  -- 2. 공구 개설이 완료된 후, 포인트 지급 함수를 호출합니다.
  perform award_points(auth.uid(), 'CREATE_GROUP_BUY');
end;
$$;