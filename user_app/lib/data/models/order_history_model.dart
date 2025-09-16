// user_app/lib/data/models/order_history_model.dart

class OrderHistoryModel {
  final int orderId;
  final String orderNumber;
  final DateTime createdAt;
  final String status;
  final int totalAmount;
  final String recipientName;
  final String recipientPhone;
  final String shippingAddress;
  final String? trackingNumber;
  final List<OrderHistoryItemModel> items;

  OrderHistoryModel({
    required this.orderId,
    required this.orderNumber,
    required this.createdAt,
    required this.status,
    required this.totalAmount,
    required this.recipientName,
    required this.recipientPhone,
    required this.shippingAddress,
    this.trackingNumber,
    required this.items,
  });

  factory OrderHistoryModel.fromJson(Map<String, dynamic> json) {
    return OrderHistoryModel(
      orderId: json['id'],
      orderNumber: json['order_number'] ?? 'ORD-${json['id'].toString().padLeft(6, '0')}',
      createdAt: DateTime.parse(json['created_at']),
      status: json['status'] ?? 'pending',
      totalAmount: json['total_amount'],
      recipientName: json['recipient_name'],
      recipientPhone: json['recipient_phone'],
      shippingAddress: json['shipping_address'],
      trackingNumber: json['tracking_number'],
      items: (json['order_items'] as List<dynamic>?)
          ?.map((item) => OrderHistoryItemModel.fromJson(item))
          .toList() ?? [],
    );
  }
}

class OrderHistoryItemModel {
  final int orderItemId; // ✅ 추가
  final int productId;
  final String productName;
  final String? productImageUrl;
  final int pricePerItem;
  final int quantity;
  final int totalPrice;

  OrderHistoryItemModel({
    required this.orderItemId, // ✅ 추가
    required this.productId,
    required this.productName,
    this.productImageUrl,
    required this.pricePerItem,
    required this.quantity,
    required this.totalPrice,
  });

  factory OrderHistoryItemModel.fromJson(Map<String, dynamic> json) {
    final pricePerItem = json['price_per_item'] ?? 0;
    final quantity = json['quantity'] ?? 0;
    
    return OrderHistoryItemModel(
      orderItemId: json['id'] ?? json['order_item_id'] ?? 0, // ✅ 추가
      productId: json['product_id'],
      productName: json['products']?['name'] ?? '상품명 없음',
      productImageUrl: json['products']?['image_url'],
      pricePerItem: pricePerItem,
      quantity: quantity,
      totalPrice: pricePerItem * quantity,
    );
  }
}