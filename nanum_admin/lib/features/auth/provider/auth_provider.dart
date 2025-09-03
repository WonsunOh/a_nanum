// ========================================
// nanum_admin/lib/features/auth/provider/auth_provider.dart (최종 수정)
// ========================================
// ========================================
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_provider.g.dart';

// ✅ 간단한 Provider만 유지 (에러 없음)
@riverpod
Stream<AuthState> authStateChange(AuthStateChangeRef ref) {
  debugPrint('🔄 [AuthProvider] Supabase 인증 상태 Stream 구독 시작');
  
  return Supabase.instance.client.auth.onAuthStateChange.map((authState) {
    debugPrint('🔄 [AuthProvider] 인증 상태 변경: ${authState.event}');
    debugPrint('👤 [AuthProvider] 사용자: ${authState.session?.user?.email}');
    return authState;
  });
}