-- 주문취소 요청 테이블
CREATE TABLE order_cancellations (
  id BIGSERIAL PRIMARY KEY,
  order_id BIGINT REFERENCES orders(id),
  user_id UUID REFERENCES auth.users(id),
  
  -- 취소 요청 정보
  cancel_reason TEXT NOT NULL,
  cancel_detail TEXT,
  
  -- 처리 상태
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  
  -- 관리자 처리 정보
  admin_id UUID REFERENCES auth.users(id),
  admin_note TEXT,
  processed_at TIMESTAMP,
  
  -- 시간 정보
  requested_at TIMESTAMP DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW()
);