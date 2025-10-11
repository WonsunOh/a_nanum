// user_app/lib/data/repositories/order_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../models/cart_item_model.dart';
import '../models/order_history_model.dart';
import '../models/order_model.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(Supabase.instance.client);
});

class OrderRepository {
  final SupabaseClient _client;
  OrderRepository(this._client);

  // 주문번호 생성 함수
  String _generateOrderNumber() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyyMMdd');
    final dateString = formatter.format(now);
    final timestamp = now.millisecondsSinceEpoch.toString().substring(5);
    return 'ORD$dateString$timestamp';
  }

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
      final orderNumber = _generateOrderNumber();

      final orderResponse = await _client.from('orders').insert({
        'user_id': userId,
        'order_number': orderNumber,
        'total_amount': totalAmount,
        'shipping_fee': shippingFee,
        'recipient_name': recipientName,
        'recipient_phone': recipientPhone,
        'shipping_address': shippingAddress,
        'status': paymentId != null ? 'confirmed' : 'pending',
      }).select().single();

      final orderId = orderResponse['id'];

      final orderItems = cartItems.map((item) => {
        'order_id': orderId,
        'product_id': item.productId,
        'quantity': item.quantity,
        'price_per_item': item.product?.discountPrice ?? item.product?.price ?? 0,
      }).toList();

      await _client.from('order_items').insert(orderItems);

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

      for (final item in cartItems) {
        await _client.from('cart_items').delete().eq('id', item.id);
      }

      return OrderModel.fromJson(orderResponse);

    } catch (e) {
      print('주문 생성 실패: $e');
      rethrow;
    }
  }

  // 바로구매 상품으로 새로운 주문을 생성합니다.
  Future<OrderModel?> createDirectOrder({
    required int productId,
    required int quantity,
    required int productPrice,
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
    final orderNumber = _generateOrderNumber();

    try {
       final orderResponse = await _client.from('orders').insert({
        'user_id': userId,
        'order_number': orderNumber,
        'total_amount': totalAmount,
        'shipping_fee': shippingFee,
        'recipient_name': recipientName,
        'recipient_phone': recipientPhone,
        'shipping_address': shippingAddress,
        'status': paymentId != null ? 'confirmed' : 'pending',
      }).select().single();

      final orderId = orderResponse['id'];

      await _client.from('order_items').insert({
        'order_id': orderId,
        'product_id': productId,
        'quantity': quantity,
        'price_per_item': productPrice,
      });

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
      
      return OrderModel.fromJson(orderResponse);
    } catch(e) {
      print('바로주문 생성 실패: $e');
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
    final response = await _client
        .from('orders')
        .select('''
          id,
          order_number, 
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

    return response
        .map<OrderHistoryModel>((order) => OrderHistoryModel.fromJson(order))
        .toList();
  } catch (e) {
    print('❌ 주문내역 조회 에러: $e');
    rethrow;
  }
}

  // 🔥🔥🔥 전체 수정: DB 함수를 호출하도록 변경
 Future<void> requestCancellation({
  required String orderNumber,
  required String reason,
  required int totalAmount,
}) async {
  final user = _client.auth.currentUser;
  if (user == null) {
    throw Exception('로그인이 필요합니다.');
  }

  try {
    // 먼저 주문 상태 확인
    final orderData = await _client
        .from('orders')
        .select('id, status')
        .eq('order_number', orderNumber)
        .eq('user_id', user.id)
        .single();

    final orderId = orderData['id'];
    final orderStatus = orderData['status'];

    // confirmed 상태면 즉시 취소 처리 (order_cancellations 기록 없음)
  if (orderStatus == 'confirmed') {
  try {
    // 1. 주문 상태를 cancelled로 변경하고 결과 확인
    print('🔄 주문 취소 시작: orderId=$orderId');
    
    final updateResult = await _client
        .from('orders')
        .update({'status': 'cancelled'})
        .eq('id', orderId)
        .select()
        .single();
    
    print('✅ 주문 상태 업데이트 완료: ${updateResult['status']}');

    // 2. payments 테이블에 환불 기록 추가 (선택사항)
    try {
      final paymentData = await _client
          .from('payments')
          .select()
          .eq('order_id', orderId)
          .eq('payment_type', 'payment')
          .maybeSingle();
      
      if (paymentData != null) {
        await _client.from('payments').insert({
          'order_id': orderId,
          'user_id': user.id,
          'amount': totalAmount,
          'status': 'refunded',
          'payment_type': 'refund',
          'method': paymentData['method'] ?? 'card',
          'approved_at': DateTime.now().toIso8601String(),
        });
        print('✅ 환불 기록 생성 완료');
      }
    } catch (e) {
      print('⚠️ 환불 기록 생성 실패 (주문은 취소됨): $e');
      // 환불 기록 실패해도 주문 취소는 이미 완료되었으므로 계속 진행
    }

    print('✅ 결제완료 상태 주문 즉시 취소 완료');
    
  } catch (e) {
    print('❌ 주문 취소 실패: $e');
    throw Exception('주문 취소 처리 중 오류가 발생했습니다: $e');
  }
} else {
      // preparing 이상의 상태는 취소 요청 생성 (order_cancellations에 기록)
      await _client.rpc(
        'request_order_cancellation',
        params: {
          'p_order_number': orderNumber,
          'p_user_id': user.id,
          'p_cancel_reason': reason,
          'p_refund_amount': totalAmount,
        },
      );
      
      print('✅ 취소 요청 생성 완료 (order_cancellations에 pending으로 기록됨)');
    }
  } on PostgrestException catch (e) {
    print('❌ 주문 취소 처리 에러: ${e.message}');
    throw Exception('주문 취소에 실패했습니다. (${e.message})');
  } catch (e) {
    print('❌ 주문 취소 중 알 수 없는 에러: $e');
    rethrow;
  }
}

}

