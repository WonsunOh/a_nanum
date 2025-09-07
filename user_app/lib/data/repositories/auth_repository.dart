import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/errors/app_exception.dart';

// Repository는 데이터 소스와의 통신을 담당합니다.
class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  // 현재 로그인된 사용자 정보 가져오기
  User? get currentUser => _client.auth.currentUser;
  
  // 로그인
  // ⭐️ 1. 이메일/비밀번호 로그인 메서드 추가
  Future<void> signInWithPassword(String email, String password) async {
    await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

// auth_repository.dart의 signUp 메서드 전체 교체

Future<void> signUp({
  required String email,
  required String password,
  required String nickname,
  required String fullName,
  String? phoneNumber,
  String? address,
  int level = 1,
}) async {
  
  final userData = {
    'full_name': fullName,
    'nickname': nickname,
    'level': level,
  };

  // ✅ 디버깅 로그 추가
  print('📱 전화번호 체크:');
  print('  - phoneNumber: "$phoneNumber"');
  print('  - isEmpty: ${phoneNumber?.isEmpty}');
  print('  - trim().isNotEmpty: ${phoneNumber?.trim().isNotEmpty}');
  
  if (phoneNumber?.trim().isNotEmpty == true) {
    userData['phone'] = phoneNumber!.trim();
    print('✅ 전화번호 userData에 추가: ${userData['phone']}');
  } else {
    print('❌ 전화번호 userData에 추가 안함');
  }
  
  if (address?.trim().isNotEmpty == true) {
    userData['address'] = address!.trim();
  }
  
  print('📦 최종 userData: $userData');
  
  try {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: userData,
    );
    
    print('✅ 회원가입 성공: ${response.user?.userMetadata}');
    
  } catch (e) {
    print('🚨 회원가입 실패: $e');
    
    final errorMessage = e.toString().toLowerCase();
    
    if (errorMessage.contains('already') || 
        errorMessage.contains('exist') ||
        errorMessage.contains('duplicate') ||
        errorMessage.contains('registered')) {
      throw const AuthenticationException('이미 가입된 이메일입니다.');
    }
    
    rethrow;
  }
}
  // 로그아웃
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // ⭐️ 구글 소셜 로그인을 처리하는 메서드
  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      // redirectTo는 딥링크/앱링크가 설정된 후에 사용됩니다.
      // redirectTo: 'io.supabase.flutterquickstart://login-callback/',
    );
  }

  // 💡 카카오 로그인 메소드 추가
  Future<void> signInWithKakao() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.kakao,
        // 💡 네이티브 앱에서 카카오톡 앱을 호출하기 위한 리디렉션 설정
        redirectTo: kIsWeb ? null : 'io.supabase.co-buy://login-callback/',
      );
    } catch (e) {
      rethrow;
    }
  }

  // 💡 네이버 로그인 메소드를 URL 실행 방식으로 변경
  Future<void> signInWithNaver() async {
    try {
      // 1. Supabase 프로젝트의 고유 URL을 가져옵니다.
      const supabaseUrl = 'YOUR_SUPABASE_URL'; // 💡 본인 프로젝트 URL로 변경!

      // 2. 네이버 로그인에 필요한 전체 URL을 직접 만듭니다.
      final redirectUrl = Uri.parse(
          '$supabaseUrl/auth/v1/authorize?provider=naver&redirect_to=io.supabase.co-buy://login-callback/');

      // 3. url_launcher를 사용해 만든 URL을 실행합니다.
      //    이렇게 하면 앱 외부의 브라우저나 네이버 앱이 열리면서 로그인 페이지가 나타납니다.
      if (await canLaunchUrl(redirectUrl)) {
        await launchUrl(redirectUrl, webOnlyWindowName: '_self');
      } else {
        throw 'Could not launch $redirectUrl';
      }
    } catch (e) {
      rethrow;
    }
  }
}

// Riverpod Provider를 통해 AuthRepository 인스턴스를 앱 전역에서 사용할 수 있게 합니다.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = Supabase.instance.client;
  return AuthRepository(client);
});