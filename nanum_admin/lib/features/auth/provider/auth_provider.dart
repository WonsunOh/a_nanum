// ========================================
// nanum_admin/lib/features/auth/provider/auth_provider.dart (최종 수정)
// ========================================
// ========================================
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_provider.g.dart';

// ✅ 간단한 Provider만 유지 (에러 없음)
@riverpod
Stream<AuthState> authStateChange(Ref ref) {
  
  return Supabase.instance.client.auth.onAuthStateChange.map((authState) {
    return authState;
  });
}