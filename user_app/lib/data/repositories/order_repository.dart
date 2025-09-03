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
  // user_app/lib/data/repositories/order_repository.dart 수정
Future<OrderModel?> createOrder({
  required List<CartItemModel> cartItems,
  required int totalAmount,
  required int shippingFee,
  required String recipientName,
  required String recipientPhone,
  required String shippingAddress,
}) async {
  final userId = _client.auth.currentUser?.id;
  if (userId == null) {
    print('❌ 로그인되지 않음');
    throw Exception('로그인이 필요합니다.');
  }

  print('🔍 OrderRepository.createOrder 시작');
  print('- 사용자 ID: $userId');
  print('- 상품 개수: ${cartItems.length}');
  
  try {
    // ⭐️ RPC 대신 직접 orders 테이블에 insert
    final orderResponse = await _client.from('orders').insert({
      'user_id': userId,
      'total_amount': totalAmount,
      'shipping_fee': shippingFee,
      'recipient_name': recipientName,
      'recipient_phone': recipientPhone,
      'shipping_address': shippingAddress,
      'status': 'pending',
    }).select().single();

    final orderId = orderResponse['id'];
    print('✅ 주문 테이블 생성: $orderId');

    // order_items 테이블에 상품들 추가
    final orderItems = cartItems.map((item) => {
      'order_id': orderId,
      'product_id': item.productId,
      'quantity': item.quantity,
      'price_per_item': item.product?.discountPrice ?? item.product?.price ?? 0,
    }).toList();

    await _client.from('order_items').insert(orderItems);
    print('✅ 주문 상품 ${orderItems.length}개 추가');

    // 장바구니에서 주문한 상품들 삭제
    for (final item in cartItems) {
      await _client.from('cart_items').delete().eq('id', item.id);
    }
    print('✅ 장바구니 정리 완료');

    // 성공적으로 생성된 주문 정보 반환
    return OrderModel(
      id: orderId,
      createdAt: DateTime.now(),
      userId: userId,
      totalAmount: totalAmount,
      shippingFee: shippingFee,
      status: 'pending',
      recipientName: recipientName,
      recipientPhone: recipientPhone,
      shippingAddress: shippingAddress,
      items: [],
    );

  } catch (e, stackTrace) {
    print('❌ OrderRepository 에러: $e');
    print('📍 스택 트레이스: $stackTrace');
    rethrow;
  }
}
  
}