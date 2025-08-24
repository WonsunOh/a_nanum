// user_app/lib/features/user/auth/viewmodel/auth_viewmodel.dart (전체 교체)

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../data/repositories/auth_repository.dart';

part 'auth_viewmodel.g.dart';

@riverpod
class AuthViewModel extends _$AuthViewModel {
  late AuthRepository _authRepository;

  @override
  Future<void> build() async {
    _authRepository = ref.watch(authRepositoryProvider);
  }

  Future<void> signInWithPassword(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authRepository.signInWithPassword(email, password);
    });
  }

  // ⭐️ 3. signUp 메서드 추가
  Future<void> signUp({required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authRepository.signUp(email: email, password: password);
    });
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signInWithGoogle();
    });
  }



// user_app/lib/features/user/auth/viewmodel/auth_viewmodel.dart
Future<void> signInWithKakao() async {
  state = const AsyncValue.loading();
  state = await AsyncValue.guard(() async {
    await ref.read(authRepositoryProvider).signInWithKakao();
  });
}



  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authRepository.signOut();
    });
  }
}