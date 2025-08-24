-- 기존의 handle_new_user 함수를 새로운 버전으로 교체합니다.
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- auth.users 테이블에서 받은 raw_user_meta_data를 사용하여 profiles 테이블에 데이터를 삽입합니다.
  INSERT INTO public.profiles (id, full_name, nickname)
  VALUES (
    new.id,
    new.raw_user_meta_data ->> 'full_name',
    new.raw_user_meta_data ->> 'nickname'
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 트리거가 이 함수를 사용하도록 다시 설정합니다. (필수는 아니지만 명확성을 위해)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();