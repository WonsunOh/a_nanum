class Order {
  final int participantId;
  final int? orderId; // ⭐️ 추가
  final String productName;
  final int quantity;
  final String? userName;
  final String? userPhone;
  final String deliveryAddress;
  final String? trackingNumber;

  Order({
    required this.participantId,
    this.orderId, // ⭐️ 추가
    required this.productName,
    required this.quantity,
    this.userName,
    this.userPhone,
    required this.deliveryAddress,
    this.trackingNumber,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      participantId: json['participant_id'] ?? json['id'] ?? 0,
      orderId: json['order_id'], // ⭐️ 추가
      productName: json['product_name']?.toString() ?? json['products']?['name']?.toString() ?? '상품명 없음',
      quantity: json['quantity'] ?? 0,
      userName: json['user_name']?.toString() ?? json['orders']?['recipient_name']?.toString(),
      userPhone: json['user_phone']?.toString() ?? json['orders']?['recipient_phone']?.toString(),
      deliveryAddress: json['delivery_address']?.toString() ?? json['orders']?['shipping_address']?.toString() ?? '주소 없음',
      trackingNumber: json['tracking_number']?.toString(),
    );
  }
}