-- Supabase 데이터베이스 스키마 개선안

-- 1. 결제 정보 테이블 추가
CREATE TABLE IF NOT EXISTS payments (
    id BIGSERIAL PRIMARY KEY,
    payment_key VARCHAR(255) UNIQUE NOT NULL, -- 토스페이먼츠, 카카오페이 등의 고유키
    order_id VARCHAR(100) NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    amount INTEGER NOT NULL, -- 결제 금액
    status VARCHAR(20) NOT NULL DEFAULT 'pending', -- pending, success, failed, cancelled
    method VARCHAR(50) NOT NULL, -- card, kakaopay, naverpay, toss, etc.
    approved_at TIMESTAMP WITH TIME ZONE,
    receipt_url TEXT, -- 영수증 URL
    raw_data JSONB, -- 결제사에서 받은 원본 데이터
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT payments_status_check CHECK (status IN ('pending', 'ready', 'in_progress', 'success', 'failed', 'cancelled')),
    CONSTRAINT payments_method_check CHECK (method IN ('card', 'kakaopay', 'naverpay', 'toss', 'payco'))
);

-- 2. 주문 테이블 개선 (결제 정보 연결)
ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_id BIGINT REFERENCES payments(id);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS order_number VARCHAR(50) UNIQUE; -- 주문번호 (사용자에게 보여줄)
ALTER TABLE orders ADD COLUMN IF NOT EXISTS delivery_request TEXT; -- 배송 요청사항
ALTER TABLE orders ADD COLUMN IF NOT EXISTS tracking_number VARCHAR(100); -- 송장번호

-- 3. 상품 리뷰 테이블 추가
CREATE TABLE IF NOT EXISTS product_reviews (
    id BIGSERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    order_item_id INTEGER, -- 실제 구매한 상품에 대한 리뷰인지 확인용
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    title VARCHAR(100),
    content TEXT,
    images TEXT[], -- 리뷰 이미지 URL 배열
    is_verified BOOLEAN DEFAULT false, -- 구매 확인된 리뷰인지
    helpful_count INTEGER DEFAULT 0, -- 도움이 됐어요 개수
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(product_id, user_id, order_item_id) -- 같은 주문 아이템에 대해 중복 리뷰 방지
);

-- 4. 리뷰 도움됨 테이블
CREATE TABLE IF NOT EXISTS review_helpful (
    id BIGSERIAL PRIMARY KEY,
    review_id BIGINT REFERENCES product_reviews(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(review_id, user_id)
);

-- 5. 쿠폰 시스템
CREATE TABLE IF NOT EXISTS coupons (
    id BIGSERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    discount_type VARCHAR(20) NOT NULL, -- 'percentage', 'fixed_amount'
    discount_value INTEGER NOT NULL,
    min_order_amount INTEGER DEFAULT 0,
    max_discount_amount INTEGER, -- 최대 할인 금액 (percentage일 때)
    usage_limit INTEGER, -- 총 사용 제한
    usage_count INTEGER DEFAULT 0,
    user_usage_limit INTEGER DEFAULT 1, -- 사용자당 사용 제한
    valid_from TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    valid_until TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT coupons_discount_type_check CHECK (discount_type IN ('percentage', 'fixed_amount'))
);

-- 6. 쿠폰 사용 이력
CREATE TABLE IF NOT EXISTS coupon_usage (
    id BIGSERIAL PRIMARY KEY,
    coupon_id BIGINT REFERENCES coupons(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    order_id BIGINT REFERENCES orders(id) ON DELETE CASCADE,
    discount_amount INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(coupon_id, order_id)
);

-- 7. 상품 조회 기록 (추천 시스템용)
CREATE TABLE IF NOT EXISTS product_views (
    id BIGSERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    session_id VARCHAR(100), -- 비로그인 사용자용
    viewed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ip_address INET,
    user_agent TEXT
);

-- 8. 알림 시스템
CREATE TABLE IF NOT EXISTS notifications (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL, -- 'order_status', 'group_buy', 'promotion', etc.
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    data JSONB, -- 추가 데이터 (딥링크 정보 등)
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 인덱스는 테이블 생성 후 별도로 생성
CREATE INDEX IF NOT EXISTS idx_notifications_user_created 
    ON notifications (user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_notifications_user_read 
    ON notifications (user_id, is_read);

-- 9. 시스템 설정 테이블 개선
ALTER TABLE settings ADD COLUMN IF NOT EXISTS category VARCHAR(50) DEFAULT 'general';
ALTER TABLE settings ADD COLUMN IF NOT EXISTS data_type VARCHAR(20) DEFAULT 'text'; -- text, number, boolean, json

-- 기본 설정값 추가
INSERT INTO settings (key, value, comment, category, data_type) VALUES
('free_shipping_threshold', '50000', '무료배송 기준 금액', 'shipping', 'number'),
('default_shipping_fee', '3000', '기본 배송비', 'shipping', 'number'),
('point_rate', '1', '적립율 (1%)', 'point', 'number'),
('max_review_images', '5', '리뷰 이미지 최대 개수', 'review', 'number')
ON CONFLICT (key) DO NOTHING;

-- 10. 인덱스 최적화
CREATE INDEX IF NOT EXISTS idx_products_category_displayed ON products(category_id, is_displayed) WHERE is_displayed = true;
CREATE INDEX IF NOT EXISTS idx_products_created_displayed ON products(created_at DESC, is_displayed) WHERE is_displayed = true;
CREATE INDEX IF NOT EXISTS idx_group_buys_status_expires ON group_buys(status, expires_at) WHERE status = 'recruiting';
CREATE INDEX IF NOT EXISTS idx_orders_user_created ON orders(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_payments_user_created ON payments(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_product_reviews_product_created ON product_reviews(product_id, created_at DESC);

-- 11. RLS (Row Level Security) 정책 개선
-- 결제 정보 보안 정책
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own payments" ON payments
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own payments" ON payments
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 리뷰 정책
ALTER TABLE product_reviews ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view reviews" ON product_reviews
    FOR SELECT USING (true);

CREATE POLICY "Users can manage own reviews" ON product_reviews
    FOR ALL USING (auth.uid() = user_id);

-- 알림 정책
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own notifications" ON notifications
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications" ON notifications
    FOR UPDATE USING (auth.uid() = user_id);

-- 12. 트리거 함수들

-- 주문번호 자동 생성 트리거
CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TRIGGER AS $$
BEGIN
    NEW.order_number = 'ORD' || TO_CHAR(NOW(), 'YYYYMMDD') || LPAD(NEW.id::text, 6, '0');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_generate_order_number
    BEFORE INSERT ON orders
    FOR EACH ROW
    EXECUTE FUNCTION generate_order_number();

-- 리뷰 도움됨 카운트 업데이트 트리거
CREATE OR REPLACE FUNCTION update_review_helpful_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE product_reviews 
        SET helpful_count = helpful_count + 1 
        WHERE id = NEW.review_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE product_reviews 
        SET helpful_count = helpful_count - 1 
        WHERE id = OLD.review_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_review_helpful_count
    AFTER INSERT OR DELETE ON review_helpful
    FOR EACH ROW
    EXECUTE FUNCTION update_review_helpful_count();

-- 13. 뷰 (View) 생성

-- 상품 평점 요약 뷰
CREATE OR REPLACE VIEW product_rating_summary AS
SELECT 
    p.id as product_id,
    p.name as product_name,
    COALESCE(ROUND(AVG(pr.rating), 2), 0) as average_rating,
    COUNT(pr.id) as review_count,
    COUNT(CASE WHEN pr.rating = 5 THEN 1 END) as rating_5_count,
    COUNT(CASE WHEN pr.rating = 4 THEN 1 END) as rating_4_count,
    COUNT(CASE WHEN pr.rating = 3 THEN 1 END) as rating_3_count,
    COUNT(CASE WHEN pr.rating = 2 THEN 1 END) as rating_2_count,
    COUNT(CASE WHEN pr.rating = 1 THEN 1 END) as rating_1_count
FROM products p
LEFT JOIN product_reviews pr ON p.id = pr.product_id
GROUP BY p.id, p.name;

-- 사용자 주문 요약 뷰
CREATE OR REPLACE VIEW user_order_summary AS
SELECT 
    u.id as user_id,
    p.nickname,
    COUNT(o.id) as total_orders,
    COALESCE(SUM(o.total_amount + o.shipping_fee), 0) as total_spent,
    MAX(o.created_at) as last_order_date,
    COUNT(CASE WHEN o.status = 'completed' THEN 1 END) as completed_orders
FROM auth.users u
LEFT JOIN profiles p ON u.id = p.id
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, p.nickname;

-- 14. 함수 개선

-- 쿠폰 적용 가능 여부 확인 함수
CREATE OR REPLACE FUNCTION can_use_coupon(
    p_coupon_code VARCHAR(50),
    p_user_id UUID,
    p_order_amount INTEGER
)
RETURNS JSON AS $$
DECLARE
    coupon_record coupons%ROWTYPE;
    user_usage_count INTEGER;
    result JSON;
BEGIN
    -- 쿠폰 정보 조회
    SELECT * INTO coupon_record
    FROM coupons
    WHERE code = p_coupon_code AND is_active = true;
    
    IF NOT FOUND THEN
        RETURN json_build_object('can_use', false, 'reason', '유효하지 않은 쿠폰입니다.');
    END IF;
    
    -- 유효기간 확인
    IF coupon_record.valid_until IS NOT NULL AND NOW() > coupon_record.valid_until THEN
        RETURN json_build_object('can_use', false, 'reason', '쿠폰 유효기간이 만료되었습니다.');
    END IF;
    
    IF NOW() < coupon_record.valid_from THEN
        RETURN json_build_object('can_use', false, 'reason', '아직 사용할 수 없는 쿠폰입니다.');
    END IF;
    
    -- 최소 주문금액 확인
    IF p_order_amount < coupon_record.min_order_amount THEN
        RETURN json_build_object('can_use', false, 'reason', '최소 주문금액을 충족하지 않습니다.');
    END IF;
    
    -- 전체 사용 한도 확인
    IF coupon_record.usage_limit IS NOT NULL AND coupon_record.usage_count >= coupon_record.usage_limit THEN
        RETURN json_build_object('can_use', false, 'reason', '쿠폰 사용 한도를 초과했습니다.');
    END IF;
    
    -- 사용자별 사용 한도 확인
    SELECT COUNT(*) INTO user_usage_count
    FROM coupon_usage
    WHERE coupon_id = coupon_record.id AND user_id = p_user_id;
    
    IF user_usage_count >= coupon_record.user_usage_limit THEN
        RETURN json_build_object('can_use', false, 'reason', '이미 사용한 쿠폰입니다.');
    END IF;
    
    -- 할인 금액 계산
    DECLARE
        discount_amount INTEGER;
    BEGIN
        IF coupon_record.discount_type = 'percentage' THEN
            discount_amount = (p_order_amount * coupon_record.discount_value / 100);
            IF coupon_record.max_discount_amount IS NOT NULL AND discount_amount > coupon_record.max_discount_amount THEN
                discount_amount = coupon_record.max_discount_amount;
            END IF;
        ELSE
            discount_amount = coupon_record.discount_value;
        END IF;
        
        RETURN json_build_object(
            'can_use', true,
            'coupon_id', coupon_record.id,
            'discount_amount', discount_amount,
            'coupon_name', coupon_record.name
        );
    END;
END;
$$ LANGUAGE plpgsql;