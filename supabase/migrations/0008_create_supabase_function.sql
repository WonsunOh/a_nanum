-- 주문 생성 트랜잭션 함수
CREATE OR REPLACE FUNCTION create_order_transaction(
  p_user_id UUID,
  p_total_amount INTEGER,
  p_shipping_fee INTEGER,
  p_recipient_name TEXT,
  p_recipient_phone TEXT,
  p_shipping_address TEXT,
  p_status TEXT DEFAULT 'pending',
  p_cart_items JSONB DEFAULT '[]'::JSONB,
  p_payment_id TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_order_id BIGINT;
  v_item JSONB;
  v_result JSON;
BEGIN
  -- 사용자 인증 확인
  IF auth.uid() != p_user_id THEN
    RAISE EXCEPTION 'Unauthorized: User ID mismatch';
  END IF;

  -- 주문 생성
  INSERT INTO orders (
    user_id, total_amount, shipping_fee, recipient_name, 
    recipient_phone, shipping_address, status
  ) VALUES (
    p_user_id, p_total_amount, p_shipping_fee, p_recipient_name,
    p_recipient_phone, p_shipping_address, p_status
  ) RETURNING id INTO v_order_id;

  -- 주문 아이템 생성
  FOR v_item IN SELECT * FROM jsonb_array_elements(p_cart_items)
  LOOP
    INSERT INTO order_items (order_id, product_id, quantity, price_per_item)
    VALUES (
      v_order_id,
      (v_item->>'product_id')::INTEGER,
      (v_item->>'quantity')::INTEGER,
      (v_item->>'price_per_item')::INTEGER
    );

    -- 장바구니 아이템 삭제
    DELETE FROM cart_items 
    WHERE id = (v_item->>'cart_item_id')::INTEGER 
    AND user_id = p_user_id;
  END LOOP;

  -- 결제 정보 저장 (있는 경우)
  IF p_payment_id IS NOT NULL THEN
    INSERT INTO payments (
      order_id, user_id, payment_key, amount, status, 
      method, payment_type, approved_at
    ) VALUES (
      v_order_id, p_user_id, p_payment_id, p_total_amount, 'completed',
      'portone', 'payment', NOW()
    );
  END IF;

  -- 결과 반환
  SELECT json_build_object(
    'id', v_order_id,
    'user_id', p_user_id,
    'total_amount', p_total_amount,
    'status', p_status,
    'created_at', NOW()
  ) INTO v_result;

  RETURN v_result;
EXCEPTION
  WHEN OTHERS THEN
    RAISE EXCEPTION 'Order creation failed: %', SQLERRM;
END;
$$;