// user_app/lib/features/user/auth/viewmodel/auth_viewmodel.dart (전체 교체)

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/utils/logger.dart';
import '../../../../data/repositories/auth_repository.dart';

part 'auth_viewmodel.g.dart';

@riverpod
class AuthViewModel extends _$AuthViewModel {
  late AuthRepository _authRepository;

  @override
  Future<void> build() async {
    _authRepository = ref.watch(authRepositoryProvider);
  }

  // ✅ 1단계: 기존 기능 + 에러 처리 + 로깅
  Future<void> signInWithPassword(String email, String password) async {
    Logger.debug('이메일 로그인 시도: $email', 'AuthViewModel');
    
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      try {
        await _authRepository.signInWithPassword(email, password);
        Logger.info('로그인 성공: $email', 'AuthViewModel');
      } catch (error, stackTrace) {
        Logger.error('로그인 실패', error, stackTrace, 'AuthViewModel');
        throw ErrorHandler.handleSupabaseError(error);
      }
    });
  }

  // ⭐️ 3. signUp 메서드 추가
  Future<void> signUp({
    required String email,
    required String password,
    required String nickname,
    required String fullName,
    String? phoneNumber,
    String? address,
    int level = 1,
  }) async {
    Logger.debug('회원가입 시도: $email, 레벨: $level', 'AuthViewModel');
    
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      try {
      await _authRepository.signUp(
        email: email,
        password: password,
        nickname: nickname,
        fullName: fullName,
        phoneNumber: phoneNumber,
        address: address,
        level: level,
      );
      Logger.info('회원가입 성공: $email, 레벨: $level', 'AuthViewModel');
    } catch (error, stackTrace) {
      Logger.error('회원가입 실패', error, stackTrace, 'AuthViewModel');
      
      print('🚨 ViewModel에서 잡은 에러:');
      print('📋 타입: ${error.runtimeType}');
      print('💬 내용: $error');
      
      // ⭐️ AuthenticationException은 그대로 전달
      if (error is AuthenticationException) {
        throw error;
      }
      
      // 다른 에러만 ErrorHandler 사용
      throw ErrorHandler.handleSupabaseError(error);
    }
  });
}

 Future<void> signInWithGoogle() async {
    Logger.debug('구글 로그인 시도', 'AuthViewModel');
    
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      try {
        await _authRepository.signInWithGoogle();
        Logger.info('구글 로그인 성공', 'AuthViewModel');
      } catch (error, stackTrace) {
        Logger.error('구글 로그인 실패', error, stackTrace, 'AuthViewModel');
        throw ErrorHandler.handleSupabaseError(error);
      }
    });
  }

  Future<void> signInWithKakao() async {
    Logger.debug('카카오 로그인 시도', 'AuthViewModel');
    
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      try {
        await _authRepository.signInWithKakao();
        Logger.info('카카오 로그인 성공', 'AuthViewModel');
      } catch (error, stackTrace) {
        Logger.error('카카오 로그인 실패', error, stackTrace, 'AuthViewModel');
        throw ErrorHandler.handleSupabaseError(error);
      }
    });
  }



  Future<void> signOut() async {
    Logger.debug('로그아웃 시도', 'AuthViewModel');
    
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      try {
        await _authRepository.signOut();
        Logger.info('로그아웃 성공', 'AuthViewModel');
      } catch (error, stackTrace) {
        Logger.error('로그아웃 실패', error, stackTrace, 'AuthViewModel');
        throw ErrorHandler.handleSupabaseError(error);
      }
    });
  }
}