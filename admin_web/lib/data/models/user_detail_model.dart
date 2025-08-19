import 'app_user_model.dart';

class UserDetail {
  final AppUser profile;
  final List<UserParticipation> participations;

  UserDetail({required this.profile, required this.participations});

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    return UserDetail(
      // 💡 AppUser.fromJson(json['profile']) 대신 아래와 같이 수정합니다.
      //    Supabase의 User 객체 구조는 조금 다르므로, 직접 필드를 매핑해줍니다.
      profile: AppUser(
        id: json['profile']['id'],
        email: json['profile']['raw_user_meta_data']?['email'] ?? '정보 없음',
        username: json['profile']['username'] ?? '프로필 없음',
        createdAt: DateTime.parse(json['profile']['created_at']),
      ),
      participations: (json['participations'] as List? ?? [])
          .map((p) => UserParticipation.fromJson(p))
          .toList(),
    );
  }
}

class UserParticipation {
  final int quantity;
  final DateTime joinedAt;
  final String status;
  final String productName;
  final String? productImageUrl;

  UserParticipation({
    required this.quantity,
    required this.joinedAt,
    required this.status,
    required this.productName,
    this.productImageUrl,
  });

  factory UserParticipation.fromJson(Map<String, dynamic> json) {
    return UserParticipation(
      quantity: json['quantity'],
      joinedAt: DateTime.parse(json['joined_at']),
      status: json['group_buy_status'],
      productName: json['product_name'],
      productImageUrl: json['product_image_url'],
    );
  }
}