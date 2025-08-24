// user_app/lib/features/user/auth/provider/auth_provider.dart (전체 교체)

// ⭐️ 이 import 구문이 누락되어 있었습니다.
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_provider.g.dart';

@riverpod
// ignore: deprecated_member_use_from_same_package
Stream<AuthState> authStateChange(AuthStateChangeRef ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
}