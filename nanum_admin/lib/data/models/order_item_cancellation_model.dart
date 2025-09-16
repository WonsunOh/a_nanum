// nanum_admin/lib/data/models/order_item_cancellation_model.dart (새 파일)

class OrderItemCancellation {
  final int id;
  final int orderItemId;
  final int orderId;
  final String userId;
  final String cancelReason;
  final String? cancelDetail;
  final int cancelQuantity;
  final int refundAmount;
  final String status; // 'pending', 'approved', 'rejected'
  final String? adminId;
  final String? adminNote;
  final DateTime? processedAt;
  final DateTime requestedAt;
  final DateTime createdAt;

  // 추가 정보 (조인으로 가져올 데이터)
  final String? productName;
  final String? userName;
  final String? userPhone;
  final int? pricePerItem;

  OrderItemCancellation({
    required this.id,
    required this.orderItemId,
    required this.orderId,
    required this.userId,
    required this.cancelReason,
    this.cancelDetail,
    required this.cancelQuantity,
    required this.refundAmount,
    required this.status,
    this.adminId,
    this.adminNote,
    this.processedAt,
    required this.requestedAt,
    required this.createdAt,
    this.productName,
    this.userName,
    this.userPhone,
    this.pricePerItem,
  });

  factory OrderItemCancellation.fromJson(Map<String, dynamic> json) {
    return OrderItemCancellation(
      id: json['id'],
      orderItemId: json['order_item_id'],
      orderId: json['order_id'],
      userId: json['user_id'],
      cancelReason: json['cancel_reason'],
      cancelDetail: json['cancel_detail'],
      cancelQuantity: json['cancel_quantity'],
      refundAmount: json['refund_amount'],
      status: json['status'] ?? 'pending',
      adminId: json['admin_id'],
      adminNote: json['admin_note'],
      processedAt: json['processed_at'] != null 
          ? DateTime.parse(json['processed_at']) 
          : null,
      requestedAt: DateTime.parse(json['requested_at'] ?? json['created_at']),
      createdAt: DateTime.parse(json['created_at']),
      productName: json['order_items']?['products']?['name'],
      userName: json['orders']?['recipient_name'],
      userPhone: json['orders']?['recipient_phone'],
      pricePerItem: json['order_items']?['price_per_item'],
    );
  }
}