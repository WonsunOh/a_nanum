import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/profile_model.dart';
import '../data/repositories/profile_repository.dart';

// 💡 1. StreamProvider로 변경하여 Supabase 인증 상태를 직접 구독합니다.
final userProvider = StreamProvider<Profile?>((ref) {
  final profileRepository = ProfileRepository();
  
  // 💡 2. Supabase의 onAuthStateChange Stream을 가져옵니다.
  final authStream = Supabase.instance.client.auth.onAuthStateChange;

  // FCM 토큰을 가져와 Supabase DB에 업데이트하는 함수
  Future<void> updateFcmToken() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId != null) {
          await Supabase.instance.client
              .from('profiles')
              .update({'fcm_token': fcmToken})
              .eq('id', userId);
          print('FCM Token Updated: $fcmToken');
        }
      }
    } catch (e) {
      print('FCM 토큰 업데이트 실패: $e');
    }
  }

  return authStream.asyncMap((authState) async {
    final session = authState.session;
    if (session != null) {
      // 💡 로그인이 감지되면, FCM 토큰을 업데이트하고 프로필 정보를 가져옵니다.
      await updateFcmToken();
      return await profileRepository.getProfile();
    } else {
      return null;
    }
  });
});