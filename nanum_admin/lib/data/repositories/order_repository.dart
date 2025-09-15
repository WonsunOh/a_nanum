// nanum_admin/lib/data/repositories/order_repository.dart (전체 수정)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/order_cancellation_model.dart';
import '../models/order_model.dart';

// ⭐️ 1. 주문 타입을 구분하기 위한 Enum을 만듭니다.
enum OrderType { shop, groupBuy }

class OrderRepository {
  final SupabaseClient _client;

  OrderRepository(this._client);
     

  // ⭐️ 2. 기존 함수를 '공동구매' 주문 전용으로 변경합니다.
  Future<List<Order>> fetchGroupBuyOrders() async {
    try {
      final response = await _client
          .from('participants')
          .select('''
            id,
            quantity,
            delivery_address,
            profiles (username, phone),
            group_buys!inner (
              status,
              products (name)
            )
          ''')
          // 공동구매 주문 중 '성공' 이후 단계의 주문들만 가져옵니다.
          .inFilter('group_buys.status', ['success', 'preparing', 'shipped', 'completed']);

      return (response as List).map((data) => Order.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error fetching successful group buy orders: $e');
      rethrow;
    }
  }

  Future<List<Order>> fetchShopOrders() async {
  try {
    debugPrint('🔍 Fetching shop orders...');

    final response = await _client
        .from('orders')
        .select('''
          id,
          status,
          recipient_name,
          recipient_phone,
          shipping_address,
          total_amount,
          order_items (
            id,
            product_id,
            quantity,
            products (name)
          )
        ''')
        .order('created_at', ascending: false);

    debugPrint('📦 Raw shop orders response: $response');

    List<Order> orders = [];

    for (final orderData in response) {
      final orderId = orderData['id']; // 실제 주문 ID (44, 45, 46, 47)
      final orderItems = orderData['order_items'] as List? ?? [];

      if (orderItems.isEmpty) {
        orders.add(Order(
          participantId: orderId, // ⭐️ 주문 ID를 participantId로 사용
          orderId: orderId, // ⭐️ orderId도 동일하게 설정
          productName: '상품 정보 없음',
          quantity: 1,
          userName: orderData['recipient_name'],
          userPhone: orderData['recipient_phone'],
          deliveryAddress: orderData['shipping_address'] ?? '',
        ));
      } else {
        for (final item in orderItems) {
          orders.add(Order(
            participantId: item['id'], // order_item의 id (18, 19, 20, 21)
            orderId: orderId, // ⭐️ 실제 주문 ID (44, 45, 46, 47)
            productName: item['products']?['name'] ?? 'Product ${item['product_id']}',
            quantity: item['quantity'] ?? 1,
            userName: orderData['recipient_name'],
            userPhone: orderData['recipient_phone'],
            deliveryAddress: orderData['shipping_address'] ?? '',
          ));
        }
      }
    }

    debugPrint('✅ Successfully processed ${orders.length} shop orders');
    return orders;
  } catch (e, stackTrace) {
    debugPrint('💥 Error in fetchShopOrders: $e');
    debugPrint('📚 Stack trace: $stackTrace');
    rethrow;
  }
}

  // 송장 번호 일괄 업데이트 RPC를 호출하는 메소드 (기존 코드 유지)
  Future<void> batchUpdateTrackingNumbers(List<Map<String, dynamic>> updates) async {
    try {
      await _client.rpc('batch_update_tracking_numbers', params: {'updates': updates});
    } catch (e) {
      debugPrint('Error batch updating tracking numbers: $e');
      rethrow;
    }
  }

  Future<void> debugTablesInfo() async {
  try {
    debugPrint('=== 🔍 DB Tables Debug Info ===');
    
    // 1. 각 테이블 존재 여부 및 데이터 확인
    final tables = ['orders', 'order_items', 'products'];
    
    for (final table in tables) {
      try {
        final response = await _client.from(table).select('*').limit(1);
        debugPrint('✅ $table: exists, sample data: $response');
      } catch (e) {
        debugPrint('❌ $table: error - $e');
      }
    }
    
    // 2. 테이블 스키마 정보 (가능하다면)
    final schemaInfo = await _client
        .rpc('get_table_info', params: {'table_names': ['orders', 'order_items', 'products']});
    debugPrint('📋 Schema info: $schemaInfo');
    
  } catch (e) {
    debugPrint('💥 Debug error: $e');
  }
}


// 주문 상태 업데이트 함수
Future<void> updateOrderStatus(int orderId, String newStatus) async {
  try {
    await _client
        .from('orders')
        .update({'status': newStatus})
        .eq('id', orderId);
    
    debugPrint('✅ Order $orderId status updated to $newStatus');
  } catch (e) {
    debugPrint('💥 Error updating order status: $e');
    rethrow;
  }
}

// 주문과 취소 요청을 함께 조회하는 함수
Future<Map<int, OrderCancellation?>> fetchOrderCancellations() async {
  try {
    final cancellations = await fetchAllCancellations();
    
    // 주문 ID를 키로 하는 맵 생성
    Map<int, OrderCancellation?> cancellationMap = {};
    for (final cancellation in cancellations) {
      cancellationMap[cancellation.orderId] = cancellation;
    }
    
    return cancellationMap;
  } catch (e) {
    debugPrint('Error fetching order cancellations: $e');
    return {};
  }
}

// 기존 fetchPendingCancellations를 fetchAllCancellations로 변경
Future<List<OrderCancellation>> fetchAllCancellations() async {
  try {
    debugPrint('🔍 Fetching all cancellations...');
    
    final response = await _client
        .from('order_cancellations')
        .select('*')
        .order('created_at', ascending: false);
    
    debugPrint('🔗 All cancellations result: $response');
    
    return (response as List)
        .map((data) => OrderCancellation.fromJson(data))
        .toList();
  } catch (e) {
    debugPrint('💥 Error fetching all cancellations: $e');
    rethrow;
  }
}


// 취소 승인
Future<void> approveCancellation(int cancellationId, String adminNote) async {
  try {
    debugPrint('✅ Approving cancellation $cancellationId');
    
    final currentUser = _client.auth.currentUser;
    
    // 취소 요청 정보 조회
    final cancellation = await _client
        .from('order_cancellations')
        .select('order_id, user_id')
        .eq('id', cancellationId)
        .single();
    
    // 상태 업데이트
    await _client
        .from('order_cancellations')
        .update({
          'status': 'approved',
          'admin_id': currentUser?.id,
          'admin_note': adminNote,
          'processed_at': DateTime.now().toIso8601String(),
        })
        .eq('id', cancellationId);
    
    await updateOrderStatus(cancellation['order_id'], 'cancelled');
    
    // ⭐️ 승인 알림 발송
    await _sendCancellationApprovedNotification(
      cancellation['user_id'], 
      cancellation['order_id'],
      adminNote,
    );
    
  } catch (e) {
    debugPrint('💥 Error approving cancellation: $e');
    rethrow;
  }
}

Future<void> _sendCancellationApprovedNotification(
  String userId, 
  int orderId, 
  String adminNote
) async {
  try {
    await _client.from('notifications').insert({
      'user_id': userId,
      'type': 'order_cancellation_approved',
      'title': '주문 취소가 승인되었습니다',
      'message': '주문번호 ORD-$orderId의 취소가 승인되었습니다.\n환불 처리가 진행됩니다.',
      'data': {
        'order_id': orderId,
        'admin_note': adminNote,
        'action_type': 'cancellation_approved'
      },
      'is_read': false,
      'created_at': DateTime.now().toIso8601String(),
    });
  } catch (e) {
    debugPrint('💥 Error sending approval notification: $e');
  }
}

// 추소 거부
Future<void> rejectCancellation(int cancellationId, String adminNote) async {
  try {
    debugPrint('❌ Rejecting cancellation $cancellationId');
    
    final currentUser = _client.auth.currentUser;
    
    // 1. 취소 요청 정보 먼저 조회
    final cancellation = await _client
        .from('order_cancellations')
        .select('order_id, user_id')
        .eq('id', cancellationId)
        .single();
    
    // 2. 취소 요청 상태 업데이트
    await _client
        .from('order_cancellations')
        .update({
          'status': 'rejected',
          'admin_id': currentUser?.id,
          'admin_note': adminNote,
          'processed_at': DateTime.now().toIso8601String(),
        })
        .eq('id', cancellationId);
    
    // 3. 주문 상태를 confirmed로 변경
    await updateOrderStatus(cancellation['order_id'], 'confirmed');
    
    // 4. ⭐️ 사용자에게 알림 발송
    await _sendCancellationRejectedNotification(
      cancellation['user_id'], 
      cancellation['order_id'],
      adminNote,
    );
    
  } catch (e) {
    debugPrint('💥 Error rejecting cancellation: $e');
    rethrow;
  }
}

// 알림 발송 함수
Future<void> _sendCancellationRejectedNotification(
  String userId, 
  int orderId, 
  String adminNote
) async {
  try {
    await _client.from('notifications').insert({
      'user_id': userId,
      'type': 'order_cancellation_rejected',
      'title': '주문 취소 요청이 거부되었습니다',
      'message': '주문번호 ORD-$orderId의 취소 요청이 거부되었습니다.\n사유: $adminNote',
      'data': {
        'order_id': orderId,
        'admin_note': adminNote,
        'action_type': 'cancellation_rejected'
      },
      'is_read': false,
      'created_at': DateTime.now().toIso8601String(),
    });
    
    debugPrint('✅ Notification sent to user $userId for rejected cancellation');
  } catch (e) {
    debugPrint('💥 Error sending notification: $e');
  }
}

// fetchOrdersWithCancellations 함수 수정
  Future<Map<int, Map<String, dynamic>>> fetchOrdersWithCancellations() async {
  try {
    debugPrint('🔍 Fetching orders with cancellations...');

    // 1. 먼저 orders만 조회
    final ordersResponse = await _client
        .from('orders')
        .select('id, status, total_amount, recipient_name, recipient_phone, shipping_address')
        .order('created_at', ascending: false);
    
    debugPrint('📦 Orders response: ${ordersResponse.length} orders');

    // 2. order_cancellations 따로 조회
    final cancellationsResponse = await _client
        .from('order_cancellations')
        .select('*')
        .order('requested_at', ascending: false);
    
    debugPrint('📦 Cancellations response: ${cancellationsResponse.length} cancellations');

    Map<int, Map<String, dynamic>> result = {};

    // 3. orders 먼저 처리
    for (final order in ordersResponse) {
      final orderId = order['id'] as int;
      result[orderId] = {
        'order_status': order['status'],
        'total_amount': order['total_amount'],
        'recipient_name': order['recipient_name'],
        'recipient_phone': order['recipient_phone'],
        'shipping_address': order['shipping_address'],
        'cancellation': null,
      };
    }

    // 4. cancellations 매핑
    for (final cancellationData in cancellationsResponse) {
      try {
        final orderId = cancellationData['order_id'] as int;
        
        debugPrint('Processing cancellation for order $orderId: ${cancellationData['status']}');
        
        if (result.containsKey(orderId)) {
          final cancellation = OrderCancellation(
            id: cancellationData['id'] as int,
            orderId: orderId,
            userId: cancellationData['user_id'] as String,
            cancelReason: cancellationData['cancel_reason'] as String? ?? '사유없음',
            cancelDetail: cancellationData['cancel_detail'] as String?,
            status: cancellationData['status'] as String? ?? 'pending',
            adminNote: cancellationData['admin_note'] as String?,
            processedAt: cancellationData['processed_at'] != null 
                ? DateTime.parse(cancellationData['processed_at'] as String)
                : null,
            requestedAt: cancellationData['requested_at'] != null 
                ? DateTime.parse(cancellationData['requested_at'] as String)
                : DateTime.now(),
            createdAt: cancellationData['created_at'] != null 
                ? DateTime.parse(cancellationData['created_at'] as String)
                : DateTime.now(),
          );
          
          result[orderId]!['cancellation'] = cancellation;
          debugPrint('✅ Added cancellation for order $orderId');
        }
      } catch (e) {
        debugPrint('❌ Error processing cancellation: $e');
        debugPrint('Cancellation data: $cancellationData');
      }
    }

    debugPrint('✅ Final result: ${result.keys.toList()}');
    result.forEach((orderId, data) {
      final cancellation = data['cancellation'] as OrderCancellation?;
      debugPrint('Order $orderId: status=${data['order_status']}, has_cancellation=${cancellation != null}, cancel_status=${cancellation?.status}');
    });

    return result;
  } catch (e) {
    debugPrint('❌ Error in fetchOrdersWithCancellations: $e');
    return {};
  }
}

}

final orderRepositoryProvider = Provider((ref) {
  return OrderRepository(Supabase.instance.client);
});