import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
// 💡 google_auth import 구문을 삭제합니다.

// 구버전(Legacy) FCM API 엔드포인트
const FCM_URL = 'https://fcm.googleapis.com/fcm/send';

serve(async (req) => {
  try {
    const { record: { id: group_buy_id, status: new_status } } = await req.json();
    if (!group_buy_id) throw new Error('Group Buy ID is missing');

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    );
    
    // 참여자 FCM 토큰 조회
    const { data: participants, error } = await supabaseAdmin
      .from('participants')
      .select('profiles(fcm_token)')
      .eq('group_buy_id', group_buy_id);

    if (error) throw error;
    const tokens = participants.map(p => p.profiles?.fcm_token).filter(t => t);

    if (tokens.length === 0) {
      return new Response(JSON.stringify({ message: 'No tokens found.' }));
    }

    // Secrets에서 서버 키(Legacy)를 가져옵니다.
    const firebaseServerKey = Deno.env.get('FCM_SERVER_KEY');
    if (!firebaseServerKey) throw new Error('FCM_SERVER_KEY is not set.');

    // 알림 메시지 생성
    let notificationMessage = '';
    if (new_status === 'preparing') notificationMessage = '주문하신 상품의 준비가 시작되었습니다! 🎁';
    if (new_status === 'shipped') notificationMessage = '주문하신 상품이 발송되었습니다! 🚚';
    
    if (notificationMessage === '') {
      return new Response(JSON.stringify({ message: 'No message for this status.' }));
    }
    
    const fcmBody = {
      registration_ids: tokens,
      notification: {
        title: '공동구매 상태 변경 알림',
        body: notificationMessage,
      },
    };

    // FCM 서버에 알림 발송 요청
    const response = await fetch(FCM_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `key=${firebaseServerKey}`,
      },
      body: JSON.stringify(fcmBody),
    });

    if (!response.ok) {
      const errorBody = await response.text();
      throw new Error(`FCM request failed: ${errorBody}`);
    }
    
    return new Response(JSON.stringify({ success: true, message: 'Notifications sent.' }));

  } catch (error) {
    console.error("Function Error:", error);
    return new Response(String(error?.message ?? error), { status: 500 });
  }
})