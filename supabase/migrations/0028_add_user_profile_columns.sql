-- profiles 테이블에 사용자 상세 정보를 저장할 컬럼들을 추가합니다.
ALTER TABLE public.profiles
ADD COLUMN nickname TEXT,
ADD COLUMN phone_number TEXT,
ADD COLUMN address TEXT;
ADD COLUMN full_name TEXT NOT NULL;

-- 닉네임은 중복되지 않도록 UNIQUE 제약 조건을 추가하는 것을 권장합니다.
ALTER TABLE public.profiles
ADD CONSTRAINT profiles_nickname_key UNIQUE (nickname);