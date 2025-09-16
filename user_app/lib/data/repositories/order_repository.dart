// user_app/lib/data/repositories/order_repository.dart (새 파일)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/cart_item_model.dart';
import '../models/order_history_model.dart';
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
  String? paymentId,
}) async {
  final user = _client.auth.currentUser;
  if (user?.id == null) {
    throw Exception('인증되지 않은 사용자입니다. 다시 로그인해주세요.');
  }

  final userId = user!.id;

  try {
    // 주문 생성
    final orderResponse = await _client.from('orders').insert({
      'user_id': userId,
      'total_amount': totalAmount,
      'shipping_fee': shippingFee,
      'recipient_name': recipientName,
      'recipient_phone': recipientPhone,
      'shipping_address': shippingAddress,
      'status': paymentId != null ? 'confirmed' : 'pending',
    }).select().single();

    final orderId = orderResponse['id'];

    // order_items 생성
    final orderItems = cartItems.map((item) => {
      'order_id': orderId,
      'product_id': item.productId,
      'quantity': item.quantity,
      'price_per_item': item.product?.discountPrice ?? item.product?.price ?? 0,
    }).toList();

    await _client.from('order_items').insert(orderItems);

    // 결제 정보 저장 (있는 경우)
    if (paymentId != null) {
      await _client.from('payments').insert({
        'order_id': orderId,
        'user_id': userId,
        'payment_key': paymentId,
        'amount': totalAmount,
        'status': 'completed',
        'method': 'card',
        'payment_type': 'payment',
        'approved_at': DateTime.now().toIso8601String(),
      });
    }

    // 장바구니 정리
    for (final item in cartItems) {
      await _client.from('cart_items').delete().eq('id', item.id);
    }

    // ✅ fromJson 사용하여 OrderModel 반환
    return OrderModel.fromJson(orderResponse);

  } catch (e) {
    print('주문 생성 실패: $e');
    rethrow;
  }
}

// 현재 사용자의 주문내역을 조회합니다.
Future<List<OrderHistoryModel>> fetchOrderHistory() async {
  final userId = _client.auth.currentUser?.id;
  if (userId == null) {
    throw Exception('로그인이 필요합니다.');
  }

  try {
    print('🔍 주문내역 조회 시작: 사용자 $userId');
    
    final response = await _client
        .from('orders')
        .select('''
          id,
          created_at,
          total_amount,
          shipping_fee,
          status,
          recipient_name,
          recipient_phone,
          shipping_address,
          tracking_number,
          order_items(
            id, 
            product_id,
            quantity,
            price_per_item,
            status,
            products(
              name,
              image_url
            ),
            order_item_cancellations(
              id,
              cancel_reason,
              cancel_detail,
              cancel_quantity,
              refund_amount,
              status,
              requested_at,
              created_at
            )
          )
        ''')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    print('✅ 주문내역 응답: ${response.length}개');
    
    // 각 주문의 부분취소 정보도 로그
    for (final order in response) {
      final orderItems = order['order_items'] as List;
      for (final item in orderItems) {
        final partialCancellations = item['order_item_cancellations'] as List?;
        if (partialCancellations?.isNotEmpty == true) {
          print('📦 주문아이템 ${item['id']}: ${partialCancellations!.length}개 부분취소');
          for (final pc in partialCancellations) {
            print('   - 부분취소 ${pc['id']}: ${pc['status']} (수량: ${pc['cancel_quantity']})');
          }
        }
      }
    }

    return response
        .map<OrderHistoryModel>((order) => OrderHistoryModel.fromJson(order))
        .toList();
  } catch (e) {
    print('❌ 주문내역 조회 에러: $e');
    rethrow;
  }
}


// 특정 주문을 취소합니다. 메서드 추가
Future<bool> cancelOrder(int orderId) async {
  final userId = _client.auth.currentUser?.id;
  if (userId == null) {
    throw Exception('로그인이 필요합니다.');
  }

  try {
    // 주문 상태 확인
    final orderResponse = await _client
        .from('orders')
        .select('status')
        .eq('id', orderId)
        .eq('user_id', userId)
        .single();

    final currentStatus = orderResponse['status'];
    if (!['pending', 'confirmed'].contains(currentStatus)) {
      throw Exception('취소할 수 없는 주문 상태입니다: $currentStatus');
    }

    // 주문 상태를 cancelled로 변경
    await _client
        .from('orders')
        .update({'status': 'cancelled'})
        .eq('id', orderId)
        .eq('user_id', userId);

    print('✅ 주문 $orderId 취소 완료');
    return true;
  } catch (e) {
    print('❌ 주문 취소 에러: $e');
    rethrow;
  }
}
}
  
