// lib/core/config/app_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // Supabase 설정
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
  // 카카오 설정
  static String get kakaoNativeAppKey => dotenv.env['KAKAO_NATIVE_APP_KEY'] ?? '';
  
  // 개발/운영 환경 구분
  static bool get isProduction => dotenv.env['ENVIRONMENT'] == 'production';
  static bool get isDevelopment => dotenv.env['ENVIRONMENT'] == 'development';
  
  // 로깅 설정
  static bool get enableLogging => isDevelopment;
  static bool get enableCrashReporting => isProduction;
  
  // Firebase 설정 (알림용)
  static String get firebaseServerKey => dotenv.env['FIREBASE_SERVER_KEY'] ?? '';
  
  // 결제 설정
  static String get portoneUserCode => dotenv.env['PORTONE_USER_CODE'] ?? '';
  static String get portoneStoreId => dotenv.env['PORTONE_STORE_ID'] ?? '';
  
  // 검증 메서드
  static void validateConfig() {
    assert(supabaseUrl.isNotEmpty, 'SUPABASE_URL이 설정되지 않았습니다.');
    assert(supabaseAnonKey.isNotEmpty, 'SUPABASE_ANON_KEY가 설정되지 않았습니다.');
    
    if (isDevelopment) {
      print('🔧 Development Mode');
      print('📍 Supabase URL: ${supabaseUrl.substring(0, 20)}...');
    }
  }
}