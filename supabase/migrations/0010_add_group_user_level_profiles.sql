-- 1. profiles 테이블에 'level' 컬럼 추가
-- level: 1(일반), 5(우수), 10(공구장) 등으로 규칙을 정합니다. 기본값은 1입니다.
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS level INT NOT NULL DEFAULT 1;


-- 2. 사용자들이 공구 개설을 '신청'하는 게시판 테이블 생성
CREATE TABLE IF NOT EXISTS public.proposals (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  proposer_id UUID NOT NULL REFERENCES public.profiles(id),
  product_name TEXT NOT NULL,
  product_url TEXT, -- 참고할 상품 링크
  reason TEXT, -- 신청 이유
  status TEXT NOT NULL DEFAULT 'pending', -- pending(검토중), approved(승인), rejected(반려)
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- 3. group_buys 테이블 수정
-- 공구장이 목표 수량을 수정할 수 있도록 target_participants 컬럼의 제약조건을 확인/수정합니다.
-- (기본적으로 수정 가능하게 되어 있으므로 별도 SQL은 필요 없을 수 있습니다.)


-- 4. RLS(행 수준 보안) 정책 수정: 특정 레벨 이상만 group_buys에 직접 INSERT 가능
-- 먼저 기존 INSERT 정책을 삭제해야 할 수 있습니다. (정책 이름 확인 필요)
-- DROP POLICY "정책이름" ON public.group_buys;

CREATE POLICY "레벨 5 이상 사용자만 공구를 개설할 수 있습니다."
ON public.group_buys FOR INSERT
TO authenticated
WITH CHECK (
  -- profiles 테이블에서 현재 사용자의 level을 가져와 5 이상인지 확인
  (SELECT level FROM public.profiles WHERE id = auth.uid()) >= 5
);

-- 사용자는 자신의 공구 신청(proposal)을 생성하고 볼 수 있습니다.
CREATE POLICY "사용자는 자신의 공구 신청을 생성할 수 있습니다."
ON public.proposals FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = proposer_id);

CREATE POLICY "사용자는 자신의 공구 신청만 볼 수 있습니다."
ON public.proposals FOR SELECT
TO authenticated
USING (auth.uid() = proposer_id);