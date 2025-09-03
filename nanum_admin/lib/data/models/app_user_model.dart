import 'package:supabase_flutter/supabase_flutter.dart';

class AppUser {
  final String id;
  final String email;
  final String username;
  final int level;
  final int points; // 포인트 필드 추가
  final String role; // 역할 필드 추가 (user, admin)
  final DateTime? emailConfirmedAt; // 이메일 인증 시간
  final DateTime createdAt;
  final DateTime? lastSignInAt; // 마지막 로그인 시간

  AppUser({
    required this.id,
    required this.email,
    required this.username,
    required this.level,
    this.points = 0,
    this.role = 'user',
    this.emailConfirmedAt,
    required this.createdAt,
    this.lastSignInAt,
  });

  // 기존 User 객체에서 생성하는 팩토리 (하위 호환성)
  factory AppUser.fromUser(User user, {String? username, int? level}) {
    return AppUser(
      id: user.id,
      email: user.email ?? '이메일 없음',
      username: username ?? '프로필 없음',
      level: level ?? 0,
      points: 0,
      role: 'user',
      // ✅ String?을 DateTime?으로 안전하게 변환
      emailConfirmedAt: user.emailConfirmedAt != null 
        ? DateTime.parse(user.emailConfirmedAt!) 
        : null,
      createdAt: DateTime.parse(user.createdAt),
      // ✅ lastSignInAt도 동일하게 처리
      lastSignInAt: user.lastSignInAt != null 
        ? DateTime.parse(user.lastSignInAt!) 
        : null,
    );
  }

  // 새로운 admin_users 뷰에서 생성하는 팩토리
  factory AppUser.fromAdminView(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      email: json['email'] ?? '',
      username: json['username'] ?? json['email'] ?? '',
      level: json['level'] ?? 1,
      points: json['points'] ?? 0,
      role: json['role'] ?? 'user',
      emailConfirmedAt: json['email_confirmed_at'] != null 
        ? DateTime.parse(json['email_confirmed_at']) 
        : null,
      createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at']) 
        : DateTime.now(),
      lastSignInAt: json['last_sign_in_at'] != null 
        ? DateTime.parse(json['last_sign_in_at']) 
        : null,
    );
  }

  // 관리자 여부 확인 편의 메소드
  bool get isAdmin => role == 'admin';
  
  // 레벨별 등급명 반환
  String get levelName {
    switch (level) {
      case 1: return '일반';
      case 5: return '우수';
      case 10: return '공구장';
      default: return '일반';
    }
  }
}