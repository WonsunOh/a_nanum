// 이 파일은 지난번에 인증 기능을 만들 때 이미 생성했습니다.
// status 필드만 다시 한번 확인해주세요.
enum GroupBuyStatus {
  recruiting,
  success,
  failed,
  preparing,
  shipped,
  completed,
}

// Product 모델을 GroupBuyModel 위에 추가해줍니다.
class Product {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int totalPrice;

  Product({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.totalPrice,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['image_url'],
      totalPrice: json['total_price'],
    );
  }
}


class GroupBuy {
  final int id;
  final String hostId;
  final int productId; // 💡 productId 필드 추가
  final int targetParticipants;
  final int currentParticipants;
  final GroupBuyStatus status;
  final DateTime expiresAt;
  final Product? product; // Product 정보를 포함하도록 수정

  GroupBuy({
    required this.id,
    required this.hostId,
    required this.productId, // 💡 생성자에 추가
    required this.targetParticipants,
    required this.currentParticipants,
    required this.status,
    required this.expiresAt,
    this.product,
  });

  // 💡 객체를 복사하며 특정 필드만 업데이트하는 copyWith 메소드 추가
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

  factory GroupBuy.fromJson(Map<String, dynamic> json) {
    return GroupBuy(
      id: json['id'],
      hostId: json['host_id'],
      productId: json['product_id'], // 💡 JSON에서 productId 가져오기
      targetParticipants: json['target_participants'],
      currentParticipants: json['current_participants'],
      status: GroupBuyStatus.values.byName(json['status']),
      expiresAt: DateTime.parse(json['expires_at']),
      // 'products' 테이블에서 조인해온 상품 정보를 Product 모델로 변환
      product: json['products'] != null
          ? Product.fromJson(json['products'])
          : null,
    );
  }
}