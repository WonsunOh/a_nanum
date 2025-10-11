// File: nanum_admin/lib/data/repositories/order_repository.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_cancellation_model.dart';
import '../models/order_item_cancellation_model.dart';
import '../models/order_model.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final supabase = Supabase.instance.client;
  return OrderRepository(supabase);
});

class OrderRepository {
  final SupabaseClient _supabase;

  OrderRepository(this._supabase);


Future<List<OrderModel>> getOrders({
  required int page,
  String? query,
  String? status,
  String? period,
  DateTime? startDate, // ✅ 추가
  DateTime? endDate, // ✅ 추가
}) async {
  const pageSize = 20;
  final offset = page * pageSize;
  var queryBuilder = _supabase.from('orders').select('''
    order_number,
    created_at,
    user_id,
    recipient_name,
    total_amount,
    status,
    shipping_address,
    recipient_phone,
    order_type,
    tracking_number,
    users:admin_users!inner(username, email), 
    order_items!inner(*, products(name))
  ''');

  // 검색어 필터
  if (query != null && query.isNotEmpty) {
    queryBuilder = queryBuilder.or('order_number.ilike.%$query%,users.username.ilike.%$query%');
  }

  // 상태 필터
  if (status != null && status != '전체') {
    final statusInEnglish = OrderStatus.values.firstWhere((e) => e.displayName == status).name;
    queryBuilder = queryBuilder.eq('status', statusInEnglish);
  } else {
    // '전체' 보기일 경우, 취소/취소요청 상태는 제외합니다.
    queryBuilder = queryBuilder.not('status', 'in', '(cancelled, cancellationRequested)');
  }
  
  // ✅ 빠른 기간 선택 필터
  if (period != null && period != 'all' && period != 'custom') {
    final now = DateTime.now();
    DateTime periodStartDate;
    
    switch (period) {
      case 'today':
        // 오늘 00:00:00부터
        periodStartDate = DateTime(now.year, now.month, now.day);
        break;
      case '1w':
        // 7일 전부터
        periodStartDate = now.subtract(const Duration(days: 7));
        break;
      case '1m':
        // 30일 전부터
        periodStartDate = now.subtract(const Duration(days: 30));
        break;
      case '3m':
        // 90일 전부터
        periodStartDate = now.subtract(const Duration(days: 90));
        break;
      case '1d': // 기존 호환성 유지
        periodStartDate = now.subtract(const Duration(days: 1));
        break;
      default:
        periodStartDate = DateTime(1970);
    }
    
    queryBuilder = queryBuilder.gte('created_at', periodStartDate.toIso8601String());
  }

  // ✅ 사용자 정의 시작일
  if (startDate != null) {
    queryBuilder = queryBuilder.gte('created_at', startDate.toIso8601String());
  }
  
  // ✅ 사용자 정의 종료일 (23:59:59까지 포함)
  if (endDate != null) {
    final endOfDay = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      23,
      59,
      59,
    );
    queryBuilder = queryBuilder.lte('created_at', endOfDay.toIso8601String());
  }

  // 정렬 및 페이징
  final response = await queryBuilder
      .order('created_at', ascending: false)
      .range(offset, offset + pageSize - 1);

  final orders = (response as List).map((item) => OrderModel.fromJson(item)).toList();
  
  // 부분 취소 정보를 가져와서 주문 데이터에 반영하는 로직
  if (orders.isNotEmpty) {
    final orderNumbers = orders.map((o) => o.orderId).toList();

    final partialCancellationsResponse = await _supabase
        .from('order_item_cancellations')
        .select('*, order_items!inner(order_id, products!inner(*)), orders!inner(order_number)')
        .inFilter('orders.order_number', orderNumbers)
        .eq('status', 'approved'); // 승인된 부분취소만 가져옵니다.

    final partialCancellations = (partialCancellationsResponse as List)
        .map((e) => OrderItemCancellation.fromJson(e))
        .toList();

    if (partialCancellations.isNotEmpty) {
      for (var order in orders) {
        final relevantCancellations = partialCancellations
            .where((c) => c.order.orderId == order.orderId)
            .toList();

        if (relevantCancellations.isNotEmpty) {
          int newTotalAmount = order.totalAmount;
          List<OrderItem> newItems = List.from(order.items);

          for (var cancellation in relevantCancellations) {
            final originalItemIndex = newItems.indexWhere(
                (item) => item.productName == cancellation.orderItem.productName);

            if (originalItemIndex != -1) {
              final originalItem = newItems[originalItemIndex];
              final newQuantity = originalItem.quantity - cancellation.cancelledQuantity;
              
              newTotalAmount -= (cancellation.orderItem.price * cancellation.cancelledQuantity);
              
              if (newQuantity > 0) {
                newItems[originalItemIndex] = OrderItem(
                  productName: originalItem.productName,
                  quantity: newQuantity,
                  price: originalItem.price,
                );
              } else {
                newItems.removeAt(originalItemIndex);
              }
            }
          }
          
          final orderIndex = orders.indexOf(order);
          orders[orderIndex] = order.copyWith(
            totalAmount: newTotalAmount,
            items: newItems,
          );
        }
      }
    }
  }
  
  return orders;
}


  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _supabase
        .from('orders')
        .update({'status': newStatus}).eq('order_number', orderId);
  }

  Future<void> batchUpdateOrders(List<Map<String, dynamic>> updates) async {
    await _supabase.from('orders').upsert(updates);
  }

  Future<OrderModel> getOrderById(String orderId) async {
    final response = await _supabase
        .from('orders')
        .select('*, users:admin_users!inner(*), order_items(*, products(*))')
        .eq('order_number', orderId)
        .single();
    return OrderModel.fromJson(response);
  }

  Future<List<OrderCancellation>> getOrderCancellations({String? status, String? searchQuery}) async {
    var query = _supabase.from('order_cancellations').select('*, orders!inner(*, users:admin_users!inner(username, email))');

    if (status != null && status != '전체') {
      query = query.eq('status', status);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or('orders.order_number.ilike.%$searchQuery%,orders.users.username.ilike.%$searchQuery%');
    }

    final response = await query.order('requested_at', ascending: false);
    return (response as List).map((e) => OrderCancellation.fromJson(e)).toList();
  }

  Future<List<OrderItemCancellation>> getOrderItemCancellations({String? status, String? searchQuery}) async {
    var query = _supabase.from('order_item_cancellations').select('''
      *, 
      order_items!inner(*, products!inner(*)), 
      orders!inner(*, users:admin_users!inner(username, email))
    ''');
    
    if (status != null && status != '전체') {
      query = query.eq('status', status);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
       query = query.or('orders.order_number.ilike.%$searchQuery%,orders.users.username.ilike.%$searchQuery%');
    }
    
    final response = await query.order('requested_at', ascending: false);
    return (response as List).map((e) => OrderItemCancellation.fromJson(e)).toList();
  }

  Future<void> approveCancellation(String cancellationId) async {
    await _supabase.rpc('approve_order_cancellation', params: {'p_cancellation_id': cancellationId});
  }

  Future<void> rejectCancellation(String cancellationId, String reason) async {
    await _supabase.from('order_cancellations').update({'status': 'rejected', 'rejection_reason': reason}).eq('cancellation_id', cancellationId);
  }

  Future<void> approvePartialCancellation(String itemCancellationId) async {
    await _supabase.rpc('approve_item_cancellation', params: {'p_item_cancellation_id': itemCancellationId});
  }

  Future<void> rejectPartialCancellation(String itemCancellationId, String reason) async {
    await _supabase.from('order_item_cancellations').update({'status': 'rejected', 'rejection_reason': reason}).eq('item_cancellation_id', itemCancellationId);
  }


  // 📌 개별 송장번호 업데이트
Future<void> updateTrackingNumber({
  required String orderId,
  required String trackingNumber,
  String? courierCompany,
}) async {
  try {
    await _supabase.from('orders').update({
      'tracking_number': trackingNumber,
      'courier_company': courierCompany,
      'status': OrderStatus.shipping.name, // 자동으로 배송중으로 변경
    }).eq('order_number', orderId);
    
    debugPrint('✅ Tracking number updated: $orderId');
  } catch (e) {
    debugPrint('❌ Error updating tracking number: $e');
    rethrow;
  }
}

// 📌 일괄 송장번호 업데이트
Future<void> batchUpdateTrackingNumbers(List<Map<String, dynamic>> updates) async {
  try {
    for (final update in updates) {
      await updateTrackingNumber(
        orderId: update['order_number'],
        trackingNumber: update['tracking_number'],
        courierCompany: update['courier_company'],
      );
    }
    debugPrint('✅ Batch tracking numbers updated: ${updates.length} orders');
  } catch (e) {
    debugPrint('❌ Error in batch update: $e');
    rethrow;
  }
}
}

