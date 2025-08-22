-- 만약을 위해 기존 제약조건을 먼저 삭제합니다.
-- 이렇게 하면 이 스크립트를 여러 번 실행해도 안전합니다.
ALTER TABLE public.group_buys DROP CONSTRAINT IF EXISTS group_buys_product_id_fkey;


-- group_buys 테이블과 products 테이블 사이에
-- 'group_buys_product_id_fkey'라는 이름의 외래 키 제약 조건을 추가합니다.
-- 이 코드는 group_buys.product_id가 products.id를 참조하도록 합니다.
ALTER TABLE public.group_buys
ADD CONSTRAINT group_buys_product_id_fkey
FOREIGN KEY (product_id) REFERENCES public.products(id)
ON DELETE CASCADE; -- 💡 상품 마스터가 삭제되면 관련된 공구도 함께 삭제되도록 설정