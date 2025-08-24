// admin_web/lib/features/auth/viewmodel/auth_viewmodel.dart (새 파일)

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_viewmodel.g.dart';

@riverpod
class AuthViewModel extends _$AuthViewModel {
  @override
  Future<void> build() async {
    // 초기화 로직 (필요 시)
  }

  Future<void> signInWithPassword(String email, String password) async {
    print('--- 1. Login attempt started ---');
    print('Email: $email');
    state = const AsyncValue.loading();

    // guard는 에러를 자동으로 잡아 state.error에 담아줍니다.
    state = await AsyncValue.guard(() async {
      try {
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        print('--- 2. Supabase login successful ---');
      } on AuthException catch (e) {
        // ⭐️ Supabase 인증 에러를 콘솔에 명확하게 출력합니다.
        print('--- 🚨 SUPABASE AUTH ERROR 🚨 ---');
        print('Message: ${e.message}');
        print('StatusCode: ${e.statusCode}');
        print('------------------------------------');
        // 잡은 에러를 다시 던져서 state.error에 담기도록 합니다.
        rethrow;
      } catch (e) {
        print('--- 🚨 UNKNOWN LOGIN ERROR 🚨 ---');
        print(e);
        print('------------------------------------');
        rethrow;
      }
    });
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await Supabase.instance.client.auth.signOut();
    });
  }
}