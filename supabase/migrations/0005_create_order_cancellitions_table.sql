-- order_cancellations 테이블 생성
CREATE TABLE IF NOT EXISTS order_cancellations (
  id BIGSERIAL PRIMARY KEY,
  order_id BIGINT REFERENCES orders(id),
  user_id UUID REFERENCES auth.users(id),
  
  cancel_reason TEXT NOT NULL,
  cancel_detail TEXT,
  
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  
  admin_id UUID REFERENCES auth.users(id),
  admin_note TEXT,
  processed_at TIMESTAMP,
  
  requested_at TIMESTAMP DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW()
);

-- orders 테이블 status에 cancel_requested 추가
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_status_check;
ALTER TABLE orders ADD CONSTRAINT orders_status_check 
  CHECK (status IN ('pending', 'confirmed', 'cancel_requested', 'cancelled', 'preparing', 'shipped', 'delivered', 'refunded'));