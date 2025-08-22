
/// ## 상품 정보 모델
/// `products` 테이블의 데이터를 담는 클래스입니다.
class Product {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int totalPrice;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.totalPrice,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'] ?? '이름 없는 상품',
      description: json['description'],
      imageUrl: json['image_url'],
      totalPrice: json['total_price'] ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }
}

/// ## 공동구매 상태 Enum
/// 공동구매의 현재 진행 상태를 나타내는 타입입니다.
enum GroupBuyStatus {
  recruiting,
  success,
  failed,
  preparing,
  shipped,
  completed,
}

/// ## 공동구매 정보 모델
/// `group_buys_with_products` 뷰의 데이터를 담는 클래스입니다.
class GroupBuy {
  final int id;
  final String hostId;
  final int productId;
  final int targetParticipants;
  final int currentParticipants;
  final GroupBuyStatus status;
  final DateTime expiresAt;
  final Product? product;

  GroupBuy({
    required this.id,
    required this.hostId,
    required this.productId,
    required this.targetParticipants,
    required this.currentParticipants,
    required this.status,
    required this.expiresAt,
    this.product,
  });

  /// ## copyWith 메소드
  /// 객체를 복사하면서 특정 필드만 업데이트할 때 사용합니다.
  GroupBuy copyWith({
    Product? product,
  }) {
    return GroupBuy(
      id: id,
      hostId: hostId,
      productId: productId,
      targetParticipants: targetParticipants,
      currentParticipants: currentParticipants,
      status: status,
      expiresAt: expiresAt,
      product: product ?? this.product,
    );
  }

  /// ## fromJson 팩토리 생성자
  /// 데이터베이스 뷰에서 받은 JSON 데이터를 GroupBuy 객체로 변환합니다.
  factory GroupBuy.fromJson(Map<String, dynamic> json) {
     return GroupBuy(
      id: json['id'],
      hostId: json['host_id'],
      productId: json['product_id'],
      targetParticipants: json['target_participants'],
      currentParticipants: json['current_participants'],
      status: GroupBuyStatus.values.byName(json['status'] ?? 'recruiting'),
      expiresAt: DateTime.parse(json['expires_at']),
      // 💡 JOIN된 데이터가 없으므로, product는 여기서 null로 초기화됩니다.
      product: json.containsKey('products') && json['products'] != null 
               ? Product.fromJson(json['products']) 
               : null,
    );
  }
}