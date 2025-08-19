-- 공구 개설과 포인트 지급을 한번에 처리하는 함수
create or replace function handle_create_group_buy(
  p_name text,
  p_total_price int,
  p_target_participants int,
  p_image_url text,
  p_description text,
  p_category_id bigint,
  p_external_product_id text
)
returns void
language plpgsql
as $$
declare
  new_product_id bigint;
begin
  -- 1. 먼저 products 테이블에 새 상품을 등록하고, 새로 생성된 id를 new_product_id 변수에 저장합니다.
  insert into public.products(name, total_price, image_url, description, category_id, external_product_id)
  values (p_name, p_total_price, p_image_url, p_description, p_category_id, p_external_product_id)
  returning id into new_product_id;

  -- 2. 위에서 받은 new_product_id를 사용하여 group_buys 테이블에 공구를 개설합니다.
  insert into public.group_buys(host_id, product_id, target_participants, expires_at)
  values (auth.uid(), new_product_id, p_target_participants, now() + interval '3 days');

  -- 3. 공구 개설이 완료된 후, 포인트 지급 함수를 호출합니다.
  perform award_points(auth.uid(), 'CREATE_GROUP_BUY');
end;
$$;