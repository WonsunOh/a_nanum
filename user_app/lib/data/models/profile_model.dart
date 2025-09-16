// user_app/lib/data/models/profile_model.dart (완전 수정 버전)
class ProfileModel {
  final String id;
  final String? fullName;
  final String? nickname;
  final String? phoneNumber;
  final String? address;
  final String? detailAddress;
  final String? postcode; // ⭐️ 우편번호 필드 추가
  final int level;
  final int points; // ⭐️ 포인트 필드 추가

  ProfileModel({
    required this.id,
    this.fullName,
    this.nickname,
    this.phoneNumber,
    this.address,
    this.detailAddress,
    this.postcode, // ⭐️ 생성자에 추가
    required this.level,
    this.points = 0, // ⭐️ 생성자에 추가
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      nickname: json['nickname'] as String?,
      phoneNumber: json['phone'] as String?,
      address: json['address'] as String?,
      detailAddress: json['detail_address'],
      postcode: json['postcode'] as String?, // ⭐️ fromJson에 추가
      level: json['level'] as int? ?? 1,
      points: json['points'] as int? ?? 0, // ⭐️ fromJson에 추가
    );
  }

  @override
  String toString() {
    return 'ProfileModel(id: $id, nickname: $nickname, fullName: $fullName, level: $level, points: $points, postcode: $postcode)';
  }
}