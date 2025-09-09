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
    debugPrint('🔍 Starting fetchShopOrders...');
    
    final response = await _client
        .from('order_items')
        .select('''
          id,
          quantity,
          order_id,
          product_id,
          price_per_item,
          status,
          orders!inner (
            id,
            recipient_name,
            recipient_phone,
            status,
            shipping_address,
            total_amount,
            shipping_fee
          ),
          products (
            id,
            name
          )
        ''');
        // ⭐️ 필터링 조건 제거하여 모든 데이터 조회
    
    debugPrint('🔗 Shop orders query result: $response');
    debugPrint('🔗 Result count: ${response.length}');
    
    if (response.isEmpty) {
      debugPrint('❌ No order items found');
      return [];
    }

    // ⭐️ 실제 DB 구조에 맞게 데이터 매핑
    final orders = (response as List).map((data) {
      debugPrint('🔄 Processing order item: $data');
      
      return Order(
        participantId: data['id'], // order_items.id 사용
        quantity: data['quantity'] ?? 0,
        productName: data['products']?['name'] ?? 'N/A',
        userName: data['orders']?['recipient_name'] ?? '정보없음',
        deliveryAddress: data['orders']?['shipping_address'] ?? '주소정보없음', 
        userPhone: data['orders']?['recipient_phone'] ?? '연락처없음',
      );
    }).toList();
    
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
    // 1. 주문 상태 조회
    final ordersResponse = await _client
        .from('orders')
        .select('id, status')
        .inFilter('id', [38, 41, 42, 43]);
    
    // 2. 모든 취소 요청 조회 (pending, approved, rejected 포함)
    final cancellations = await fetchAllCancellations();
    
    Map<int, Map<String, dynamic>> result = {};
    
    // 주문 상태 매핑
    for (final order in ordersResponse) {
      final orderId = order['id'] as int;
      result[orderId] = {
        'order_status': order['status'],
        'cancellation': null,
      };
    }
    
    // 취소 요청 정보 추가 (가장 최근 것만)
    for (final cancellation in cancellations) {
      if (result.containsKey(cancellation.orderId)) {
        // 이미 다른 취소 요청이 있다면 더 최근 것으로 교체
        final existing = result[cancellation.orderId]!['cancellation'] as OrderCancellation?;
        if (existing == null || cancellation.createdAt.isAfter(existing.createdAt)) {
          result[cancellation.orderId]!['cancellation'] = cancellation;
        }
      }
    }
    
    return result;
  } catch (e) {
    debugPrint('Error fetching orders with cancellations: $e');
    return {};
  }
}

}

final orderRepositoryProvider = Provider((ref) {
  return OrderRepository(Supabase.instance.client);
});