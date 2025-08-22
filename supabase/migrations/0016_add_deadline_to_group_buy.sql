-- group_buys 테이블에 마감일을 저장할 'deadline' 컬럼 추가
ALTER TABLE public.group_buys
ADD COLUMN IF NOT EXISTS deadline DATE;