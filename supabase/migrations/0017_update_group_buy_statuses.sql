create or replace function update_group_buy_statuses()
returns void
language plpgsql
as $$
begin
  -- 1. 목표 수량에 도달한 공구를 'success'로 변경
  update public.group_buys
  set status = 'success'
  where status = 'recruiting' and current_participants >= target_participants;

  -- 2. 마감일이 지났지만 목표 수량에 도달하지 못한 공구를 'failed'로 변경
  update public.group_buys
  set status = 'failed'
  where status = 'recruiting' and deadline < current_date;
end;
$$;