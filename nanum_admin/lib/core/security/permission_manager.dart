// lib/core/security/permission_manager.dart
import 'package:supabase_flutter/supabase_flutter.dart';

import '../errors/app_exception.dart';

class PermissionManager {
  static const String adminRole = 'admin';
  static const String userRole = 'user';
  static const String moderatorRole = 'moderator';

  /// 현재 사용자의 역할 확인
  static String? getCurrentUserRole() {
    final user = Supabase.instance.client.auth.currentUser;
    return user?.userMetadata?['role'] as String?;
  }

  /// 관리자 권한 확인
  static bool isAdmin() {
    return getCurrentUserRole() == adminRole;
  }

  /// 사용자 권한 확인
  static bool isUser() {
    return getCurrentUserRole() == userRole;
  }

  /// 모더레이터 권한 확인
  static bool isModerator() {
    return getCurrentUserRole() == moderatorRole;
  }

  /// 로그인 상태 확인
  static bool isAuthenticated() {
    return Supabase.instance.client.auth.currentUser != null;
  }

  /// 권한 검증 (Exception 발생)
  static void requireAuthentication() {
    if (!isAuthenticated()) {
      throw const AuthenticationException('로그인이 필요합니다.');
    }
  }

  static void requireAdmin() {
    requireAuthentication();
    if (!isAdmin()) {
      throw const AuthenticationException('관리자 권한이 필요합니다.');
    }
  }

  /// 안전한 권한 검증 (bool 반환)
  static bool canAccessAdminPanel() {
    return isAuthenticated() && isAdmin();
  }

  static bool canManageProducts() {
    return isAuthenticated() && (isAdmin() || isModerator());
  }

  static bool canManageOrders() {
    return isAuthenticated() && isAdmin();
  }
}