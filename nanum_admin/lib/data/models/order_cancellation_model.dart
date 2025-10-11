// File: nanum_admin/lib/data/models/order_cancellation_model.dart
import 'order_model.dart';

class OrderCancellation {
  final String cancellationId;
  // ✅ final String orderId; // 중복 필드 제거
  final DateTime requestedAt;
  final String reason;
  final int refundedAmount;
  final String status;
  final OrderModel order; 

  // ✅ orderId getter 추가
  String get orderId => order.orderId;

  OrderCancellation({
    required this.cancellationId,
    required this.requestedAt,
    required this.reason,
    required this.refundedAmount,
    required this.status,
    required this.order,
  });

  factory OrderCancellation.fromJson(Map<String, dynamic> json) {
    // 🔥🔥🔥 수정: orders 데이터가 null일 경우를 대비
    final orderData = json['orders'] as Map<String, dynamic>?;

    return OrderCancellation(
      cancellationId: json['cancellation_id'] as String? ?? '',
      requestedAt: DateTime.tryParse(json['requested_at'] as String? ?? '') ?? DateTime.now(),
      reason: json['reason'] as String? ?? '',
      refundedAmount: json['refunded_amount'] as int? ?? 0,
      status: json['status'] as String? ?? 'unknown',
      // 🔥🔥🔥 수정: orderData가 null일 경우 빈 Map을 전달하여 앱 비정상 종료 방지
      order: OrderModel.fromJson(orderData ?? {}),
    );
  }
}

