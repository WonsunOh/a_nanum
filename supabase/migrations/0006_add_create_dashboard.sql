create or replace function get_dashboard_metrics()
returns table (
  total_users bigint,
  total_sales bigint,
  active_deals bigint,
  successful_deals bigint
)
language sql
as $$
  select
    -- 총 회원 수 (profiles 테이블 기준)
    (select count(*) from public.profiles) as total_users,
    -- 총 매출 (모집 성공한 공구의 총액 합산)
    (select sum(p.total_price)
     from public.group_buys gb
     join public.products p on gb.product_id = p.id
     where gb.status = 'success') as total_sales,
    -- 현재 모집 중인 공구 수
    (select count(*) from public.group_buys where status = 'recruiting') as active_deals,
    -- 모집 성공한 공구 수
    (select count(*) from public.group_buys where status = 'success') as successful_deals;
$$;