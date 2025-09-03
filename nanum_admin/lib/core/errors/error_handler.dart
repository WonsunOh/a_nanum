// lib/core/errors/error_handler.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_exception.dart';

class ErrorHandler {
  /// Supabase 에러를 앱 에러로 변환
  static AppException handleSupabaseError(Object error) {
    if (error is PostgrestException) {
      return DatabaseException(
        _getReadableErrorMessage(error.message),
        code: error.code,
        details: error.details,
      );
    } else if (error is AuthException) {
      return AuthenticationException(
        _getReadableAuthMessage(error.message),
        code: error.statusCode,
      );
    } else {
      return NetworkException('네트워크 오류가 발생했습니다.');
    }
  }

  /// 사용자 친화적인 에러 메시지로 변환
  static String _getReadableErrorMessage(String message) {
    if (message.contains('duplicate key')) return '이미 존재하는 데이터입니다.';
    if (message.contains('not found')) return '요청한 데이터를 찾을 수 없습니다.';
    if (message.contains('connection')) return '서버 연결에 실패했습니다.';
    return '처리 중 오류가 발생했습니다.';
  }

  static String _getReadableAuthMessage(String message) {
    if (message.contains('Invalid login')) return '이메일 또는 비밀번호가 틀렸습니다.';
    if (message.contains('User not found')) return '등록되지 않은 사용자입니다.';
    if (message.contains('Email already registered')) return '이미 가입된 이메일입니다.';
    return '인증 오류가 발생했습니다.';
  }

  /// 개발 모드에서만 상세 에러 로깅
  static void logError(Object error, StackTrace? stackTrace, [String? context]) {
    if (kDebugMode) {
      debugPrint('🚨 Error ${context ?? ''}: $error');
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }
}