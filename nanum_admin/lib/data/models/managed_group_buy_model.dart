/// 관리자 페이지의 '공구 관리' 화면에서 사용할 데이터 모델입니다.
class ManagedGroupBuy {
  final int id;
  final String productName;
  final String hostName;
  final String status;
  final int currentParticipants;
  final int targetParticipants;

  ManagedGroupBuy({
    required this.id,
    required this.productName,
    required this.hostName,
    required this.status,
    required this.currentParticipants,
    required this.targetParticipants,
  });

  factory ManagedGroupBuy.fromJson(Map<String, dynamic> json) {
    return ManagedGroupBuy(
      id: json['id'],
      // 중첩된 JSON 데이터에서 안전하게 값을 추출합니다.
      productName: json['products']?['name'] ?? '알 수 없는 상품',
      hostName: json['profiles']?['username'] ?? '알 수 없는 사용자',
      status: json['status'],
      currentParticipants: json['current_participants'],
      targetParticipants: json['target_participants'],
    );
  }
}