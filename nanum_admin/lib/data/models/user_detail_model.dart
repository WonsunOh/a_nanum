import 'app_user_model.dart';

class UserDetailModel {
  final AppUser profile;
  final List<UserParticipation> participations;

  UserDetailModel({required this.profile, required this.participations});

  factory UserDetailModel.fromJson(Map<String, dynamic> json) {

     final profileData = json['profile'] as Map<String, dynamic>? ?? {};
    return UserDetailModel(
      profile: AppUser(
        id: profileData['id'] ?? '알 수 없는 ID',
        email: profileData['raw_user_meta_data']?['email'] ?? '정보 없음',
        username: profileData['username'] ?? '프로필 없음',
        
        // ⭐️ 1. level이 null일 경우 기본값으로 0을 사용하도록 수정합니다.
        level: profileData['level'] ?? 0, 

        // ⭐️ 2. createdAt도 null일 수 있으므로 안전하게 처리합니다.
        createdAt: profileData['created_at'] != null
            ? DateTime.parse(profileData['created_at'])
            : DateTime.now(),
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