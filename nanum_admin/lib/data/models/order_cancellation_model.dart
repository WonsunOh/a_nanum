// nanum_admin/lib/data/models/order_cancellation_model.dart (새 파일)

class OrderCancellation {
  final int id;
  final int orderId;
  final String userId;
  final String cancelReason;
  final String? cancelDetail;
  final String status;
  final String? adminId;
  final String? adminNote;
  final DateTime? processedAt;
  final DateTime requestedAt;
  final DateTime createdAt;

  OrderCancellation({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.cancelReason,
    this.cancelDetail,
    required this.status,
    this.adminId,
    this.adminNote,
    this.processedAt,
    required this.requestedAt,
    required this.createdAt,
  });

  factory OrderCancellation.fromJson(Map<String, dynamic> json) {
    return OrderCancellation(
      id: json['id'],
      orderId: json['order_id'],
      userId: json['user_id'],
      cancelReason: json['cancel_reason'] ?? '',
      cancelDetail: json['cancel_detail'],
      status: json['status'],
      adminId: json['admin_id'],
      adminNote: json['admin_note'],
      processedAt: json['processed_at'] != null 
          ? DateTime.parse(json['processed_at']) 
          : null,
      requestedAt: DateTime.parse(json['requested_at']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  
}