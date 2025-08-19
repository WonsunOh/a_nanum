-- public 스키마의 profiles 테이블에
-- phone 이라는 이름의 컬럼을 추가합니다.
-- TEXT 타입으로 만들어 다양한 형식(예: 010-1234-5678)을 저장할 수 있게 합니다.
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS phone TEXT;