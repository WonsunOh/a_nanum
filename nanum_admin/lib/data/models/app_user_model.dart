import 'package:supabase_flutter/supabase_flutter.dart';

class AppUser {
  final String id;
  final String email;
  final String username;
  final int level;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.email,
    required this.username,
    required this.level,
    required this.createdAt,
  });

  factory AppUser.fromUser(User user, {String? username, int? level}) {
    return AppUser(
      id: user.id,
      email: user.email ?? '이메일 없음',
      username: username ?? '프로필 없음',
      level: level ?? 0,
      // 💡 user.createdAt이 String이므로 DateTime.parse()로 변환합니다.
      createdAt: DateTime.parse(user.createdAt),
    );
  }
}