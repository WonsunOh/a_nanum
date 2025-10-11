// File: nanum_admin/lib/data/models/cancellation_model.dart
import 'package:intl/intl.dart';

enum CancellationType {
  full,
  partial,
}

class CancellationModel {
  final String id; // cancellation_id 또는 order_item_cancellation_id
  final String orderId;
  final DateTime requestedAt;
  final String reason;
  final CancellationType type;
  final int? refundedAmount; // 전체 취소 시 환불 금액
  final String? productName; // 부분 취소 시 상품명
  final int? quantity; // 부분 취소 시 수량

  CancellationModel({
    required this.id,
    required this.orderId,
    required this.requestedAt,
    required this.reason,
    required this.type,
    this.refundedAmount,
    this.productName,
    this.quantity,
  });

  factory CancellationModel.fromFullCancellation(Map<String, dynamic> json) {
    return CancellationModel(
      id: json['cancellation_id'],
      orderId: json['order_number'],
      requestedAt: DateTime.parse(json['requested_at']),
      reason: json['reason'],
      type: CancellationType.full,
      refundedAmount: json['refunded_amount'],
    );
  }

  factory CancellationModel.fromPartialCancellation(Map<String, dynamic> json) {
    return CancellationModel(
      id: json['item_cancellation_id'],
      orderId: json['orders']?['order_number'] ?? 'N/A',
      requestedAt: DateTime.parse(json['requested_at']),
      reason: json['reason'],
      type: CancellationType.partial,
      productName: json['order_items']?['products']?['name'] ?? '알 수 없는 상품',
      quantity: json['cancelled_quantity'],
    );
  }
  
  String get formattedRequestedAt => DateFormat('yyyy-MM-dd HH:mm').format(requestedAt);
}