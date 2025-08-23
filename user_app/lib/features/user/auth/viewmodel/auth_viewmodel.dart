import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/auth_repository.dart';

// 인증 관련 상태를 관리하는 ViewModel입니다. (StateNotifier 사용)
class AuthViewModel extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _repository;
  
  AuthViewModel(this._repository) : super(const AsyncValue.data(null));

  // 로그인 로직
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading(); // 로딩 상태로 변경
    state = await AsyncValue.guard(() {
      return _repository.signInWithEmail(email: email, password: password);
    });
  }

  // 회원가입 로직
  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() {
      return _repository.signUp(email: email, password: password);
    });
  }
  
  // 💡 로그아웃 로직을 단순화합니다.
  Future<void> signOut() async {
    // state를 변경하는 모든 코드를 제거하고, repository 호출만 남깁니다.
    try {
      await _repository.signOut();
    } catch (e) {
      // 에러가 발생하면 콘솔에 출력합니다.
      print('로그아웃 에러: $e');
    }
  }
}

// Riverpod Provider를 통해 ViewModel 인스턴스를 UI에서 사용할 수 있게 합니다.
final authViewModelProvider = StateNotifierProvider.autoDispose<AuthViewModel, AsyncValue<void>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthViewModel(repository);
});