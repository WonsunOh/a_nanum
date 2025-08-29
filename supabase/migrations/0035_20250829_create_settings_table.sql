-- supabase/migrations/0035_create_settings_table.sql

-- 1. settings 테이블 생성
CREATE TABLE public.settings (
    key text PRIMARY KEY NOT NULL,
    value text,
    comment text,
    created_at timestamptz DEFAULT now() NOT NULL,
    updated_at timestamptz DEFAULT now() NOT NULL
);

-- 2. 테이블 및 컬럼에 대한 설명 추가 (주석)
COMMENT ON TABLE public.settings IS '쇼핑몰의 각종 설정을 저장하는 키-값 테이블';
COMMENT ON COLUMN public.settings.key IS '설정 항목의 고유 키 (예: shipping_fee)';
COMMENT ON COLUMN public.settings.value IS '설정 값';
COMMENT ON COLUMN public.settings.comment IS '해당 설정에 대한 설명';

-- 3. Row Level Security (RLS) 활성화
ALTER TABLE public.settings ENABLE ROW LEVEL SECURITY;

-- 4. 관리자만 접근 가능하도록 정책(Policy) 설정
-- 관리자는 모든 작업을 할 수 있습니다.
CREATE POLICY "Allow full access to admin"
ON public.settings
FOR ALL
USING (auth.jwt() ->> 'user_role' = 'admin')
WITH CHECK (auth.jwt() ->> 'user_role' = 'admin');

-- 5. 기본 설정값 삽입
INSERT INTO public.settings (key, value, comment) VALUES
    ('shipping_fee', '3000', '기본 배송비'),
    ('company_name', '(주)나눔', '회사명'),
    ('business_number', '123-45-67890', '사업자 등록번호'),
    ('ceo_name', '홍길동', '대표자 이름'),
    ('address', '서울특별시 강남구 테헤란로 123', '사업장 주소'),
    ('telecommunication_sales_number', '2025-서울강남-01234', '통신판매업 신고번호'),
    ('customer_service_phone', '1588-0000', '고객센터 전화번호'),
    ('customer_service_email', 'help@nanum.com', '고객센터 이메일'),
    ('logo_image_url', '', '쇼핑몰 로고 이미지 URL (비워두면 텍스트 로고 사용)');