// nanum_admin/lib/features/auth/viewmodel/auth_viewmodel.dart (최종 수정)
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_viewmodel.g.dart';

@riverpod
class AuthViewModel extends _$AuthViewModel {
  @override
  Future<void> build() async {
    // 초기화
  }

  Future<void> signInWithPassword(String email, String password) async {
    
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
    });
  }

  Future<void> signOut() async {
    
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await Supabase.instance.client.auth.signOut();
    });
  }
}