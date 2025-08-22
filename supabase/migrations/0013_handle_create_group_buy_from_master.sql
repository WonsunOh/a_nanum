create or replace function handle_create_group_buy_from_master(
  p_product_id bigint,
  p_target_participants int,
  p_initial_quantity int,
  p_deadline date
)
returns void
language plpgsql
as $$
declare
  new_group_buy_id bigint;
begin
  insert into public.group_buys(
    host_id, 
    product_id, 
    target_participants, 
    current_participants, 
    deadline, 
    expires_at -- 💡 expires_at 컬럼 추가
  )
  values (
    auth.uid(), 
    p_product_id, 
    p_target_participants, 
    p_initial_quantity, 
    p_deadline,
    (p_deadline + interval '1 day')::timestamptz - interval '1 second' -- 💡 마감일 자정 직전으로 설정
  )
  returning id into new_group_buy_id;

  -- 개설자를 첫 번째 참여자로 participants 테이블에 추가
  insert into public.participants(group_buy_id, user_id, delivery_address, quantity)
  values (new_group_buy_id, auth.uid(), '기본 배송지', p_initial_quantity);

  -- 포인트 지급 함수 호출
  perform award_points(auth.uid(), 'CREATE_GROUP_BUY');
end;
$$;