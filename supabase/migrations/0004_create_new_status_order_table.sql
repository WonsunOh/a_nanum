-- orders 테이블의 status에 새로운 상태 추가
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_status_check;
ALTER TABLE orders ADD CONSTRAINT orders_status_check 
  CHECK (status IN ('pending', 'confirmed', 'cancel_requested', 'cancelled', 'preparing', 'shipped', 'delivered', 'refunded'));