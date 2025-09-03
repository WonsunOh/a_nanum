// lib/core/utils/logger.dart
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

enum LogLevel { debug, info, warning, error, critical }

class Logger {
  static const String _tag = '🌟 NanumStore';

  /// 디버그 로그 - 개발 중에만 표시
  static void debug(String message, [String? tag]) {
    if (AppConfig.enableLogging) {
      _log(LogLevel.debug, message, tag);
    }
  }

  /// 정보 로그 - 일반적인 동작 상황
  static void info(String message, [String? tag]) {
    if (AppConfig.enableLogging) {
      _log(LogLevel.info, message, tag);
    }
  }

  /// 경고 로그 - 주의가 필요한 상황
  static void warning(String message, [String? tag]) {
    if (AppConfig.enableLogging) {
      _log(LogLevel.warning, message, tag);
    }
  }

  /// 에러 로그 - 오류 발생 상황
  static void error(String message, [Object? error, StackTrace? stackTrace, String? tag]) {
    _log(LogLevel.error, message, tag);
    
    if (error != null) {
      debugPrint('Error details: $error');
    }
    
    if (stackTrace != null && kDebugMode) {
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// 중요한 에러 로그 - 외부 서비스로 전송할 수 있는 심각한 오류
  static void critical(String message, [Object? error, StackTrace? stackTrace, String? tag]) {
    _log(LogLevel.critical, message, tag);
    
    // 프로덕션 환경에서는 Crashlytics 등에 전송
    if (AppConfig.isProduction && AppConfig.enableCrashReporting) {
      // FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
    }
  }

  /// 네트워크 요청 로그
  static void networkRequest(String method, String url, [Map<String, dynamic>? data]) {
    if (AppConfig.enableLogging) {
      debugPrint('🌐 $method $url');
      if (data != null) {
        debugPrint('📤 Request: $data');
      }
    }
  }

  /// 네트워크 응답 로그
  static void networkResponse(int statusCode, String url, [dynamic data]) {
    if (AppConfig.enableLogging) {
      final statusIcon = statusCode >= 200 && statusCode < 300 ? '✅' : '❌';
      debugPrint('$statusIcon $statusCode $url');
      if (data != null && kDebugMode) {
        debugPrint('📥 Response: $data');
      }
    }
  }

  /// 내부 로그 출력 메서드
  static void _log(LogLevel level, String message, [String? tag]) {
    final timestamp = DateTime.now().toIso8601String();
    final tagPrefix = tag != null ? '[$tag] ' : '';
    final levelIcon = _getLogIcon(level);
    
    debugPrint('$levelIcon $_tag $tagPrefix$message ($timestamp)');
  }

  /// 로그 레벨별 아이콘 반환
  static String _getLogIcon(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🐛';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
      case LogLevel.critical:
        return '🚨';
    }
  }
}