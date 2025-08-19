-- 특정 사용자의 상세 정보와 전체 참여(주문) 목록을 반환하는 함수
create or replace function get_user_details(p_user_id uuid)
returns json
language sql
as $$
  select
    json_build_object(
      'profile', (select to_json(p) from profiles p where id = p_user_id),
      'participations', (
        select json_agg(
          json_build_object(
            'quantity', pt.quantity,
            'joined_at', pt.joined_at,
            'group_buy_status', gb.status,
            'product_name', pr.name,
            'product_image_url', pr.image_url
          )
        )
        from participants pt
        join group_buys gb on pt.group_buy_id = gb.id
        join products pr on gb.product_id = pr.id
        where pt.user_id = p_user_id
      )
    )
$$;