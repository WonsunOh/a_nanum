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