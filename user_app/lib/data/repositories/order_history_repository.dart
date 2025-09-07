// user_app/lib/data/repositories/order_history_repository.dart (수정)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_history_model.dart';

final orderHistoryRepositoryProvider = Provider<OrderHistoryRepository>((ref) {
  return OrderHistoryRepository(Supabase.instance.client);
});

class OrderHistoryRepository {
  final SupabaseClient _client;
  OrderHistoryRepository(this._client);

  Future<List<OrderHistoryModel>> fetchUserOrderHistory() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('로그인이 필요합니다');
    }

    try {
      print('주문내역 조회 시작: 사용자 $userId');
      
      final response = await _client
          .from('orders')
          .select('''
            id,
            order_number,
            status,
            total_amount,
            recipient_name,
            recipient_phone,
            shipping_address,
            tracking_number,
            created_at,
            order_items (
              id,
              product_id,
              quantity,
              price_per_item,
              products (
                name,
                image_url
              )
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      print('주문내역 응답: ${response.length}개');
      
      return response.map((item) => OrderHistoryModel.fromJson(item)).toList();
    } catch (e) {
      print('주문내역 조회 에러: $e');
      rethrow;
    }
  }
}