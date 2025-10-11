// File: nanum_admin/lib/data/models/order_item_cancellation_model.dart
import 'order_model.dart';

class OrderItemCancellation {
  final String itemCancellationId;
  final DateTime requestedAt;
  final int cancelledQuantity;
  final String reason;
  final String status;
  final OrderModel order; 
  final OrderItem orderItem; 

  OrderItemCancellation({
    required this.itemCancellationId,
    required this.requestedAt,
    required this.cancelledQuantity,
    required this.reason,
    required this.status,
    required this.order,
    required this.orderItem,
  });

  factory OrderItemCancellation.fromJson(Map<String, dynamic> json) {
    // 🔥🔥🔥 수정: orders와 order_items 데이터가 null일 경우를 대비
    final orderData = json['orders'] as Map<String, dynamic>?;
    final orderItemData = json['order_items'] as Map<String, dynamic>?;

    return OrderItemCancellation(
      itemCancellationId: json['item_cancellation_id'] as String? ?? '',
      requestedAt: DateTime.tryParse(json['requested_at'] as String? ?? '') ?? DateTime.now(),
      cancelledQuantity: json['cancelled_quantity'] as int? ?? 0,
      reason: json['reason'] as String? ?? '',
      status: json['status'] as String? ?? 'unknown',
      // 🔥🔥🔥 수정: null일 경우 빈 Map을 전달하여 앱 비정상 종료 방지
      order: OrderModel.fromJson(orderData ?? {}),
      orderItem: OrderItem.fromJson(orderItemData ?? {}),
    );
  }
}

