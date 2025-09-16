// user_app/lib/data/models/order_item_cancellation_model.dart

class OrderItemCancellationModel {
  final int id;
  final int orderItemId;
  final int orderId;
  final String userId;
  final String cancelReason;
  final String? cancelDetail;
  final int cancelQuantity;
  final int refundAmount;
  final String status;
  final DateTime requestedAt;
  final DateTime? processedAt;

  OrderItemCancellationModel({
    required this.id,
    required this.orderItemId,
    required this.orderId,
    required this.userId,
    required this.cancelReason,
    this.cancelDetail,
    required this.cancelQuantity,
    required this.refundAmount,
    required this.status,
    required this.requestedAt,
    this.processedAt,
  });

  factory OrderItemCancellationModel.fromJson(Map<String, dynamic> json) {
    return OrderItemCancellationModel(
      id: json['id'],
      orderItemId: json['order_item_id'],
      orderId: json['order_id'],
      userId: json['user_id'],
      cancelReason: json['cancel_reason'],
      cancelDetail: json['cancel_detail'],
      cancelQuantity: json['cancel_quantity'],
      refundAmount: json['refund_amount'],
      status: json['status'],
      requestedAt: DateTime.parse(json['requested_at']),
      processedAt: json['processed_at'] != null 
          ? DateTime.parse(json['processed_at']) 
          : null,
    );
  }
}