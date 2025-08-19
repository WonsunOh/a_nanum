-- 포인트 부여 및 레벨업 처리를 위한 함수
create or replace function award_points(p_user_id uuid, p_action text)
returns void
language plpgsql
security definer
as $$
declare
  points_to_award int;
  new_total_points int;
  new_level int;
begin
  -- 1. 행동(p_action) 타입에 따라 지급할 포인트를 결정합니다.
  case p_action
    when 'CREATE_GROUP_BUY' then points_to_award := 20; -- 공구 개설 시 20 포인트
    when 'JOIN_GROUP_BUY' then points_to_award := 10;   -- 공구 참여 시 10 포인트
    -- TODO: 'SUCCESS_HOST' (공구 성공시킨 공구장), 'FIRST_REPLY' 등 다양한 조건 추가 가능
    else points_to_award := 0;
  end case;

  -- 2. profiles 테이블의 기존 포인트에 새로운 포인트를 더하고, 그 결과를 new_total_points 변수에 저장합니다.
  update public.profiles
  set points = points + points_to_award
  where id = p_user_id
  returning points into new_total_points;

  -- 3. 새로 계산된 총 포인트를 기준으로 레벨업 조건을 확인합니다.
  select level into new_level from public.profiles where id = p_user_id;

  -- 예시 레벨업 규칙 (이 부분을 자유롭게 수정하세요)
  if new_total_points >= 1000 and new_level < 10 then
    new_level := 10; -- 1000점 이상이면 '공구장' 레벨
  elsif new_total_points >= 500 and new_level < 5 then
    new_level := 5; -- 500점 이상이면 '우수회원' 레벨
  elsif new_total_points >= 100 and new_level < 2 then
    new_level := 2; -- 100점 이상이면 '일반회원' 레벨
  end if;

  -- 4. 변경된 레벨을 profiles 테이블에 업데이트합니다.
  update public.profiles
  set level = new_level
  where id = p_user_id;

end;
$$;