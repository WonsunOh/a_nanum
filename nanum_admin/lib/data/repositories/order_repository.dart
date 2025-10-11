// File: nanum_admin/lib/data/repositories/order_repository.dart
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
      users:admin_users!inner(username, email), 
      order_items!inner(*, products(name))
    ''');

    if (query != null && query.isNotEmpty) {
      queryBuilder = queryBuilder.or('order_number.ilike.%$query%,users.username.ilike.%$query%');
    }

    if (status != null && status != '전체') {
       final statusInEnglish = OrderStatus.values.firstWhere((e) => e.displayName == status).name;
       queryBuilder = queryBuilder.eq('status', statusInEnglish);
    } else {
      // '전체' 보기일 경우, 취소/취소요청 상태는 제외합니다.
      queryBuilder = queryBuilder.not('status', 'in', '(cancelled, cancellationRequested)');
    }
    
    if (period != null && period != 'all') {
      final now = DateTime.now();
      DateTime startDate;
      switch (period) {
        case '1d': startDate = now.subtract(const Duration(days: 1)); break;
        case '1w': startDate = now.subtract(const Duration(days: 7)); break;
        case '1m': startDate = now.subtract(const Duration(days: 30)); break;
        default: startDate = DateTime(1970);
      }
      queryBuilder = queryBuilder.gte('created_at', startDate.toIso8601String());
    }

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
              final originalItemIndex = newItems.indexWhere((item) => item.productName == cancellation.orderItem.productName);

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
}

