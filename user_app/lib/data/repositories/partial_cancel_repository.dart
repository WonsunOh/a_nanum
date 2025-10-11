// user_app/lib/data/repositories/partial_cancel_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_item_cancellation_model.dart';

final partialCancelRepositoryProvider = Provider<PartialCancelRepository>((ref) {
  return PartialCancelRepository(Supabase.instance.client);
});

class PartialCancelRepository {
  final SupabaseClient _client;
  PartialCancelRepository(this._client);

  // 부분 취소 요청 제출
  Future<Map<String, dynamic>> requestPartialCancellation({
    required int orderItemId,
    required String cancelReason,
    String? cancelDetail,
    required int cancelQuantity,
  }) async {
    try {
      final result = await _client.rpc('request_partial_order_cancellation', params: {
        'p_order_item_id': orderItemId,
        'p_cancel_reason': cancelReason,
        'p_cancel_detail': cancelDetail,
        'p_cancel_quantity': cancelQuantity,
      });

      return result as Map<String, dynamic>;
    } catch (e) {
      print('부분 취소 요청 실패: $e');
      rethrow;
    }
  }

Future<int> processCancelledItem({
  required int orderItemId,
  required int cancelQuantity,
  required bool isFullCancel,
}) async {
  try {
    // order_items에서 현재 정보 조회
    final itemData = await _client
        .from('order_items')
        .select('quantity, price_per_item, order_id')
        .eq('id', orderItemId)
        .single();
    
    final currentQuantity = itemData['quantity'] as int;
    final orderId = itemData['order_id'] as int;
    
    if (isFullCancel || cancelQuantity >= currentQuantity) {
      // 전체 취소인 경우 status만 cancelled로 변경 (quantity는 그대로 유지)
      await _client
          .from('order_items')
          .update({
            'status': 'cancelled',
            // quantity는 변경하지 않음 (0으로 만들면 체크 제약 위반)
          })
          .eq('id', orderItemId);
      print('✅ 전체 취소 - status를 cancelled로 변경');
    } else {
      // 부분 취소인 경우 수량만 감소
      final newQuantity = currentQuantity - cancelQuantity;
      if (newQuantity > 0) {
        await _client
            .from('order_items')
            .update({
              'quantity': newQuantity,
            })
            .eq('id', orderItemId);
        print('✅ 부분 취소 - quantity를 $currentQuantity에서 $newQuantity로 감소');
      } else {
        // newQuantity가 0이 되는 경우에도 status만 변경
        await _client
            .from('order_items')
            .update({
              'status': 'cancelled',
            })
            .eq('id', orderItemId);
        print('✅ 수량이 0이 되어 status를 cancelled로 변경');
      }
    }

    print('✅ 상품 부분취소 처리 완료: orderItemId=$orderItemId, 취소수량=$cancelQuantity');
    
    return orderId;
    
  } catch (e) {
    print('❌ 상품 부분취소 처리 실패: $e');
    rethrow;
  }
}

// updateOrderStatusAfterPartialCancel 메서드도 수정
Future<void> updateOrderStatusAfterPartialCancel(int orderId) async {
  try {
    // 해당 주문의 모든 order_items 조회
    final items = await _client
        .from('order_items')
        .select('status, quantity, price_per_item')
        .eq('order_id', orderId);
    
    // 모든 아이템이 취소되었는지 확인 (status가 cancelled인지로 판단)
    final allCancelled = items.every((item) => item['status'] == 'cancelled');
    
    // 새로운 총액 계산 (cancelled가 아닌 항목만)
    int newTotal = 0;
    for (final item in items) {
      if (item['status'] != 'cancelled') {
        final qty = item['quantity'] as int? ?? 0;
        final price = item['price_per_item'] as int? ?? 0;
        newTotal += qty * price;
      }
    }
    
    // shipping_fee 조회
    final orderData = await _client
        .from('orders')
        .select('shipping_fee')
        .eq('id', orderId)
        .single();
    
    final shippingFee = orderData['shipping_fee'] as int? ?? 0;
    
    if (allCancelled) {
      // 모든 상품이 취소된 경우 주문을 cancelled로 변경
      await _client
          .from('orders')
          .update({
            'status': 'cancelled',
            'total_amount': 0,  // 전체 취소 시 0
          })
          .eq('id', orderId);
      print('✅ 모든 상품 취소로 주문 상태를 cancelled로 변경');
    } else {
      // 일부만 취소된 경우 총액만 업데이트
      await _client
          .from('orders')
          .update({
            'total_amount': newTotal + shippingFee
          })
          .eq('id', orderId);
      print('✅ 주문 총액 재계산 완료: ${newTotal + shippingFee}원');
    }
    
  } catch (e) {
    print('❌ 주문 상태/총액 업데이트 실패: $e');
    rethrow;
  }
}

  // 특정 주문의 부분 취소 내역 조회
  Future<List<OrderItemCancellationModel>> getOrderCancellations(int orderId) async {
    try {
      final response = await _client
          .from('order_item_cancellations')
          .select()
          .eq('order_id', orderId)
          .order('requested_at', ascending: false);

      return response
          .map((json) => OrderItemCancellationModel.fromJson(json))
          .toList();
    } catch (e) {
      print('부분 취소 내역 조회 실패: $e');
      return [];
    }
  }
}