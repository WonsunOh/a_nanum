-- profiles 테이블에 level 컬럼을 추가합니다.
-- 정수(INTEGER) 타입이며, 기본값은 1로 설정합니다.
ALTER TABLE public.profiles
ADD COLUMN level INTEGER NOT NULL DEFAULT 1;