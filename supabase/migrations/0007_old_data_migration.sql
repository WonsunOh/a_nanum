-- 기존 주문들의 user_id를 올바르게 설정
-- 이는 수동으로 각 주문의 실제 소유자를 확인해야 함
UPDATE orders 
SET user_id = '799b3f84-6176-4898-b3af-66f3a288f59b'
WHERE id = 38 AND user_id IS NULL;

-- 다른 NULL user_id 주문들도 확인 및 업데이트
SELECT id, recipient_name, recipient_phone, created_at 
FROM orders 
WHERE user_id IS NULL;