class Order {
  final int participantId;
  final int quantity;
  final String productName;
  final String? userName; // 배송받을 사람 이름 (추후 profiles에 추가)
  final String deliveryAddress;
  final String? userPhone; // 배송 연락처 (추후 profiles에 추가)

  Order({
    required this.participantId,
    required this.quantity,
    required this.productName,
    this.userName,
    required this.deliveryAddress,
    this.userPhone,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    // JOIN 쿼리의 복잡한 구조를 파싱합니다.
    return Order(
      participantId: json['id'],
      quantity: json['quantity'],
      productName: json['group_buys']?['products']?['name'] ?? 'N/A',
      userName: json['profiles']?['username'] ?? '정보 없음',
      deliveryAddress: json['delivery_address'],
      userPhone: json['profiles']?['phone'] ?? '정보 없음', // profiles 테이블에 phone 컬럼이 있다고 가정
    );
  }
}