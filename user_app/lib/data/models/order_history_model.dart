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
      orderNumber: json['order_number'] as String? ?? '',
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
  final int orderItemId;
  final int productId;
  final String productName;
  final String? productImageUrl;
  final int pricePerItem;
  final int quantity;
  final int totalPrice;
  final String status;
  final List<PartialCancellationInfo>? partialCancellations;

  OrderHistoryItemModel({
    required this.orderItemId,
    required this.productId,
    required this.productName,
    this.productImageUrl,
    required this.pricePerItem,
    required this.quantity,
    required this.totalPrice,
    this.status = 'active',
    this.partialCancellations,
  });

  factory OrderHistoryItemModel.fromJson(Map<String, dynamic> json) {
    final pricePerItem = json['price_per_item'] ?? 0;
    final quantity = json['quantity'] ?? 0;
    
    // 부분취소 정보 파싱
    List<PartialCancellationInfo>? partialCancellations;
    if (json['order_item_cancellations'] != null) {
      partialCancellations = (json['order_item_cancellations'] as List)
          .map((item) => PartialCancellationInfo.fromJson(item))
          .toList();
    }
    
    return OrderHistoryItemModel(
      orderItemId: json['id'] ?? json['order_item_id'] ?? 0,
      productId: json['product_id'],
      productName: json['products']?['name'] ?? '상품명 없음',
      productImageUrl: json['products']?['image_url'],
      pricePerItem: pricePerItem,
      quantity: quantity,
      totalPrice: pricePerItem * quantity,
      status: json['status'] ?? 'active',
      partialCancellations: partialCancellations,
    );
  }

  // ✅ null 체크 수정
  bool get hasPendingCancellation => partialCancellations?.any((pc) => pc.status == 'pending') ?? false;
  bool get hasApprovedCancellation => partialCancellations?.any((pc) => pc.status == 'approved') ?? false;
  bool get hasRejectedCancellation => partialCancellations?.any((pc) => pc.status == 'rejected') ?? false;
  
  int get totalCancelledQuantity {
    return partialCancellations?.fold<int>(0, (sum, pc) => 
      pc.status == 'approved' ? (sum ?? 0) + pc.cancelQuantity : (sum ?? 0)) ?? 0;
  }
  
  int get effectiveQuantity => quantity - totalCancelledQuantity;
}

class PartialCancellationInfo {
  final int id;
  final String cancelReason;
  final String? cancelDetail;
  final int cancelQuantity;
  final int refundAmount;
  final String status;
  final DateTime requestedAt;

  PartialCancellationInfo({
    required this.id,
    required this.cancelReason,
    this.cancelDetail,
    required this.cancelQuantity,
    required this.refundAmount,
    required this.status,
    required this.requestedAt,
  });

  factory PartialCancellationInfo.fromJson(Map<String, dynamic> json) {
    return PartialCancellationInfo(
      id: json['id'],
      cancelReason: json['cancel_reason'] ?? '',
      cancelDetail: json['cancel_detail'],
      cancelQuantity: json['cancel_quantity'] ?? 0,
      refundAmount: json['refund_amount'] ?? 0,
      status: json['status'] ?? 'pending',
      requestedAt: DateTime.parse(json['requested_at'] ?? json['created_at']),
    );
  }
}