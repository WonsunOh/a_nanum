// user_app/lib/data/repositories/order_repository.dart (새 파일)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/cart_item_model.dart';
import '../models/order_model.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(Supabase.instance.client);
});

class OrderRepository {
  final SupabaseClient _client;
  OrderRepository(this._client);

  // 장바구니 상품들로 새로운 주문을 생성합니다.
  Future<OrderModel?> createOrder({
    required List<CartItemModel> cartItems,
    required int totalAmount,
    required int shippingFee,
    required String recipientName,
    required String recipientPhone,
    required String shippingAddress,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('로그인이 필요합니다.');

    // PostgREST의 트랜잭션을 사용하여 주문 생성과 아이템 추가를 한번에 처리합니다.
    // 이렇게 하면 중간에 에러가 발생했을 때 모든 작업이 취소되어 데이터 정합성을 지킬 수 있습니다.
    final orderData = await _client.rpc('create_order_from_cart', params: {
      'p_user_id': userId,
      'p_total_amount': totalAmount,
      'p_shipping_fee': shippingFee,
      'p_recipient_name': recipientName,
      'p_recipient_phone': recipientPhone,
      'p_shipping_address': shippingAddress,
      'p_cart_items': cartItems
          .map((item) => {
                'product_id': item.productId,
                'quantity': item.quantity,
                'price_per_item': item.product?.price ?? 0
              })
          .toList()
    });

    if (orderData != null) {
      // TODO: 주문 성공 후 반환된 데이터를 OrderModel로 변환하는 로직 추가
      return null;
    }
    return null;
  }
}