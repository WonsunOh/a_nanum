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
}