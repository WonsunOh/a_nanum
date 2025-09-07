-- 1단계: 현재 정책들 확인 및 백업
SELECT schemaname, tablename, policyname, cmd, qual, with_check
FROM pg_policies 
WHERE tablename IN ('orders', 'order_items', 'order_cancellations');

-- 2단계: 모든 관련 정책 제거
DROP POLICY IF EXISTS "Users can see their own orders" ON orders;
DROP POLICY IF EXISTS "Users can insert their own orders" ON orders;
DROP POLICY IF EXISTS "Users can update their own orders" ON orders;
DROP POLICY IF EXISTS "Enable read access for users based on user_id" ON orders;
DROP POLICY IF EXISTS "Enable insert for users based on user_id" ON orders;
DROP POLICY IF EXISTS "Enable update for users based on user_id" ON orders;

DROP POLICY IF EXISTS "Users can see their own order items" ON order_items;
DROP POLICY IF EXISTS "Users can insert their own order items" ON order_items;
DROP POLICY IF EXISTS "Users can update their own order items" ON order_items;

-- 3단계: 스키마 정규화
ALTER TABLE orders ALTER COLUMN user_id TYPE UUID USING user_id::UUID;
ALTER TABLE orders ALTER COLUMN user_id SET NOT NULL;

-- 4단계: order_cancellations 테이블 생성
CREATE TABLE IF NOT EXISTS order_cancellations (
  id BIGSERIAL PRIMARY KEY,
  order_id BIGINT REFERENCES orders(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  cancel_reason TEXT NOT NULL,
  cancel_detail TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  admin_id UUID REFERENCES auth.users(id),
  admin_note TEXT,
  processed_at TIMESTAMP,
  requested_at TIMESTAMP DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW()
);

-- 5단계: orders 테이블 상태 제약조건 업데이트
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_status_check;
ALTER TABLE orders ADD CONSTRAINT orders_status_check 
  CHECK (status IN ('pending', 'confirmed', 'cancel_requested', 'cancelled', 'preparing', 'shipped', 'delivered', 'refunded'));

-- 6단계: 새로운 RLS 정책 생성
CREATE POLICY "orders_select_policy" ON orders
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "orders_insert_policy" ON orders
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "orders_update_policy" ON orders
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "order_items_select_policy" ON order_items
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM orders 
      WHERE orders.id = order_items.order_id 
      AND orders.user_id = auth.uid()
    )
  );

CREATE POLICY "order_items_insert_policy" ON order_items
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM orders 
      WHERE orders.id = order_items.order_id 
      AND orders.user_id = auth.uid()
    )
  );

CREATE POLICY "order_cancellations_select_policy" ON order_cancellations
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "order_cancellations_insert_policy" ON order_cancellations
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "order_cancellations_update_policy" ON order_cancellations
  FOR UPDATE USING (auth.uid() = user_id);