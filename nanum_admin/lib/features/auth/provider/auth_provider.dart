// admin_web/lib/features/auth/provider/auth_provider.dart (새 파일)

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_provider.g.dart';

// ⭐️ Supabase의 인증 상태 변경 Stream을 앱 전체에서 사용할 수 있는 Provider로 만듭니다.
@riverpod
Stream<AuthState> authStateChange(AuthStateChangeRef ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
}