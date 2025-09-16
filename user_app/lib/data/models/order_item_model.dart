// user_app/lib/data/models/order_item_model.dart

class OrderItemModel {
  final int id;
  final int orderId;
  final int productId;
  final int quantity;
  final int pricePerItem;
  final String status; // ✅ 새로 추가
  final String? productName;
  final String? productImageUrl;

  OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.pricePerItem,
    this.status = 'active', // ✅ 기본값 설정
    this.productName,
    this.productImageUrl,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'],
      orderId: json['order_id'],
      productId: json['product_id'],
      quantity: json['quantity'],
      pricePerItem: json['price_per_item'],
      status: json['status'] ?? 'active', // ✅ 상태 추가
      productName: json['products']?['name'],
      productImageUrl: json['products']?['image_url'],
    );
  }

  // 취소 가능 여부 확인
  bool get canCancel => status == 'active';
  
  // 취소 요청 중 여부 확인  
  bool get isCancelRequested => status == 'cancel_requested';
  
  // 취소 완료 여부 확인
  bool get isCancelled => status == 'cancelled';

  // 총 금액 계산
  int get totalAmount => quantity * pricePerItem;
}