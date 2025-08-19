import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// Repository는 데이터 소스와의 통신을 담당합니다.
class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  // 현재 로그인된 사용자 정보 가져오기
  User? get currentUser => _client.auth.currentUser;
  
  // 로그인
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      // 에러 처리는 ViewModel에서 담당하도록 rethrow 합니다.
      rethrow;
    }
  }

  // 회원가입
  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    try {
      await _client.auth.signUp(
        email: email,
        password: password,
      );
    } catch (e) {
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