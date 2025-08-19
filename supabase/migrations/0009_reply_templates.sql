-- 답변 템플릿을 저장할 테이블
CREATE TABLE IF NOT EXISTS public.reply_templates (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  title TEXT NOT NULL UNIQUE, -- 템플릿 제목 (예: "배송 지연 안내")
  content TEXT NOT NULL, -- 템플릿 내용
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 관리자만 접근 가능하도록 RLS 정책을 추가할 수 있으나, 
-- service_role_key를 사용하므로 우선은 생략합니다.