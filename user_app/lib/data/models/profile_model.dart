// user_app/lib/data/models/profile_model.dart (전체 교체)

class ProfileModel {
  final String id;
  final String? fullName; // ⭐️ 이름 필드 추가
  final String? nickname;
  final String? phoneNumber;
  final String? address;

  ProfileModel({
    required this.id,
    this.fullName, // ⭐️ 생성자에 추가
    this.nickname,
    this.phoneNumber,
    this.address,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String?, // ⭐️ fromJson에 추가
      nickname: json['nickname'] as String?,
      phoneNumber: json['phone_number'] as String?,
      address: json['address'] as String?,
    );
  }
}