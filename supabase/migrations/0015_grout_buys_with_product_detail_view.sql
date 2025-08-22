-- group_buys와 products 테이블을 JOIN한 결과를 보여주는 '뷰' 생성
CREATE OR REPLACE VIEW public.group_buys_with_products AS
SELECT
  gb.*, -- group_buys 테이블의 모든 컬럼
  p.name AS product_name,
  p.description AS product_description,
  p.image_url AS product_image_url,
  p.total_price AS product_total_price
FROM
  public.group_buys gb
JOIN
  public.products p ON gb.product_id = p.id;