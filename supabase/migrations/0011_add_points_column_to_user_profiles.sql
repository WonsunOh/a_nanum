-- profiles 테이블에 'points' 컬럼 추가
-- 사용자가 활동할 때마다 이 점수가 누적됩니다. 기본값은 0입니다.
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS points INT NOT NULL DEFAULT 0;