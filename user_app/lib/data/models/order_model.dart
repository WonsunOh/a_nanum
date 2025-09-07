// user_app/lib/data/models/order_model.dart

import 'order_item_model.dart';

class OrderModel {
  final int id;
  final DateTime createdAt;
  final String userId;
  final int totalAmount;
  final int shippingFee;
  final String status;
  final String recipientName;
  final String recipientPhone;
  final String shippingAddress;
  final List<OrderItemModel> items; // 주문에 포함된 상품 목록

  OrderModel({
    required this.id,
    required this.createdAt,
    required this.userId,
    required this.totalAmount,
    required this.shippingFee,
    required this.status,
    required this.recipientName,
    required this.recipientPhone,
    required this.shippingAddress,
    this.items = const [],
  });

  // ✅ fromJson 메서드 추가
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      userId: json['user_id'],
      totalAmount: json['total_amount'],
      shippingFee: json['shipping_fee'] ?? 0,
      status: json['status'],
      recipientName: json['recipient_name'],
      recipientPhone: json['recipient_phone'],
      shippingAddress: json['shipping_address'],
      items: [], // 기본값으로 빈 리스트
    );
  }
}
