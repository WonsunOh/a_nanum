import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';

class ProfileRepository {
  final _client = Supabase.instance.client;

  // 현재 로그인한 사용자의 프로필 정보를 가져옵니다.
  Future<Profile?> getProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return Profile.fromJson(response);
    } catch (e) {
      print('프로필 정보 가져오기 실패: $e');
      return null;
    }
  }
}