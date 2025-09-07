CREATE OR REPLACE FUNCTION request_order_cancellation(
  p_order_id BIGINT,
  p_user_id UUID,
  p_cancel_reason TEXT,
  p_cancel_detail TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_order_status TEXT;
  v_cancellation_id BIGINT;
  v_result JSON;
BEGIN
  -- 사용자 인증 확인
  IF auth.uid() != p_user_id THEN
    RAISE EXCEPTION 'Unauthorized: User ID mismatch';
  END IF;

  -- 주문 존재 및 소유권 확인
  SELECT status INTO v_order_status
  FROM orders
  WHERE id = p_order_id AND user_id = p_user_id;

  IF v_order_status IS NULL THEN
    RAISE EXCEPTION 'Order not found or access denied';
  END IF;

  -- 취소 가능한 상태 확인
  IF v_order_status NOT IN ('pending', 'confirmed', 'preparing') THEN
    RAISE EXCEPTION 'Order cannot be cancelled in current status: %', v_order_status;
  END IF;

  -- 취소 요청 생성
  INSERT INTO order_cancellations (
    order_id, user_id, cancel_reason, cancel_detail, status
  ) VALUES (
    p_order_id, p_user_id, p_cancel_reason, p_cancel_detail, 'pending'
  ) RETURNING id INTO v_cancellation_id;

  -- 주문 상태 업데이트
  UPDATE orders 
  SET status = 'cancel_requested' 
  WHERE id = p_order_id;

  SELECT json_build_object(
    'cancellation_id', v_cancellation_id,
    'order_id', p_order_id,
    'status', 'pending'
  ) INTO v_result;

  RETURN v_result;
EXCEPTION
  WHEN OTHERS THEN
    RAISE EXCEPTION 'Cancellation request failed: %', SQLERRM;
END;
$$;