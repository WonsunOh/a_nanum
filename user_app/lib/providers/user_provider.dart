import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/profile_model.dart';
import '../data/repositories/profile_repository.dart';

// 💡 1. StreamProvider로 변경하여 Supabase 인증 상태를 직접 구독합니다.
final userProvider = StreamProvider<ProfileModel?>((ref) {
  final profileRepository = ref.watch(profileRepositoryProvider);
  
  // 💡 2. Supabase의 onAuthStateChange Stream을 가져옵니다.
  final authStream = Supabase.instance.client.auth.onAuthStateChange;

  // 💡 3. 인증 상태가 변경될 때마다(예: 로그인, 로그아웃) 프로필 정보를 가져옵니다.
  return authStream.asyncMap((authState) async {
    final session = authState.session;
    if (session != null) {
      // 💡 로그인이 감지되면, getProfile()을 호출하여 프로필 정보를 반환합니다.
      return await profileRepository.getProfile();
    } else {
      // 💡 로그아웃이 감지되면, null을 반환합니다.
      return null;
    }
  });
});