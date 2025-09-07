// user_app/lib/data/repositories/order_cancellation_repository.dart (완전한 구현)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderCancellationRepository {
  final SupabaseClient _client;
  OrderCancellationRepository(this._client);

  Future<int> requestCancellation({
  required int orderId,
  required String reason,
  String? detail,
}) async {
  final user = _client.auth.currentUser;
  if (user?.id == null) {
    throw Exception('인증되지 않은 사용자입니다.');
  }

  final userId = user!.id;

  try {
    print('📝 취소 요청 시작 - OrderID: $orderId');
    
    // 1. 주문 존재 및 소유권 확인
    final order = await _client
        .from('orders')
        .select('status, user_id')
        .eq('id', orderId)
        .single();

    print('📊 현재 주문 상태: ${order['status']}');

    if (order['user_id'] != userId) {
      throw Exception('본인의 주문만 취소할 수 있습니다.');
    }

    final orderStatus = order['status'];
    if (!['pending', 'confirmed', 'preparing'].contains(orderStatus)) {
      throw Exception('취소할 수 없는 주문 상태입니다: $orderStatus');
    }

    // 2. 취소 요청 생성
    final response = await _client.from('order_cancellations').insert({
      'order_id': orderId,
      'user_id': userId,
      'cancel_reason': reason,
      'cancel_detail': detail,
      'status': 'pending',
    }).select().single();

    print('✅ order_cancellations 삽입 완료: ${response['id']}');

    // 3. 주문 상태 업데이트 (디버깅 추가)
    print('🔄 orders 테이블 상태 업데이트 시작...');
    
    final updateResult = await _client
        .from('orders')
        .update({'status': 'cancel_requested'})
        .eq('id', orderId)
        .select();  // select() 추가하여 결과 확인
        
    print('✅ orders 테이블 업데이트 완료: $updateResult');

    // 4. 업데이트 결과 재확인
    final updatedOrder = await _client
        .from('orders')
        .select('status')
        .eq('id', orderId)
        .single();
        
    print('🔍 업데이트 후 주문 상태: ${updatedOrder['status']}');

    return response['id'];
  } catch (e) {
    print('❌ 취소 요청 실패: $e');
    throw Exception('주문 취소 요청 실패: ${e.toString()}');
  }
}


  Future<Map<String, dynamic>?> getCancellationStatus(int orderId) async {
    try {
      final response = await _client
          .from('order_cancellations')
          .select('*')
          .eq('order_id', orderId)
          .order('created_at', ascending: false)
          .limit(1);

      if (response.isEmpty) return null;
      return response.first;
    } catch (e) {
      print('취소 상태 조회 에러: $e');
      return null;
    }
  }
}

// ✅ Provider 정의
final orderCancellationRepositoryProvider = Provider<OrderCancellationRepository>((ref) {
  return OrderCancellationRepository(Supabase.instance.client);
});