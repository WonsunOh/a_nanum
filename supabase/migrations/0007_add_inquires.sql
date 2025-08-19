-- 1. 고객 문의를 저장할 테이블 생성
CREATE TABLE IF NOT EXISTS public.inquiries (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  author_id UUID NOT NULL REFERENCES public.profiles(id),
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending', -- pending(답변 대기), answered(답변 완료)
  reply TEXT, -- 관리자의 답변
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  answered_at TIMESTAMPTZ
);

-- 2. 사용자는 자신의 문의만 작성할 수 있는 RLS 정책
CREATE POLICY "사용자는 자신의 문의를 작성할 수 있습니다."
ON public.inquiries FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = author_id);

-- 3. 사용자는 자신의 문의만 볼 수 있는 RLS 정책
CREATE POLICY "사용자는 자신의 문의만 볼 수 있습니다."
ON public.inquiries FOR SELECT
TO authenticated
USING (auth.uid() = author_id);

-- 4. 관리자는 모든 문의를 보고 답변(수정)할 수 있도록 설정
-- (admin_web 프로젝트에서 service_role_key를 사용하므로 별도 정책이 필요 없지만,
--  만약을 위해 admin 역할만 접근 가능하도록 정책을 추가할 수도 있습니다.)