-- 1. 송장 번호 업데이트를 위한 사용자 정의 데이터 타입을 생성합니다.
--    (participant_id와 tracking_number를 한 쌍으로 묶어줍니다.)
CREATE TYPE public.tracking_update AS (
  p_id BIGINT,
  t_num TEXT
);

-- 2. 위에서 만든 타입의 배열을 받아, 여러 주문을 한번에 업데이트하는 함수를 생성합니다.
CREATE OR REPLACE FUNCTION public.batch_update_tracking_numbers(updates tracking_update[])
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
  -- 배열을 순회하기 위한 변수
  upd tracking_update;
BEGIN
  -- 전달받은 배열(updates)을 순회하면서 각 항목을 처리합니다.
  FOREACH upd IN ARRAY updates
  LOOP
    -- participants 테이블에서 id가 일치하는 주문을 찾아 송장번호를 업데이트합니다.
    UPDATE public.participants
    SET tracking_number = upd.t_num
    WHERE id = upd.p_id;

    -- TODO: 여기에 사용자에게 '배송 시작' 알림을 보내는 로직 추가 가능
  END LOOP;
END;
$$;