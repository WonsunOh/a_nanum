// user_app/lib/data/repositories/profile_repository.dart (전체 교체)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';

// ⭐️ 1. Riverpod Provider를 사용하여 Repository 인스턴스를 앱 전체에 제공합니다.
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(Supabase.instance.client);
});

class ProfileRepository {
  final SupabaseClient _client;
  ProfileRepository(this._client);

  /// 현재 로그인한 사용자의 프로필 정보를 가져옵니다.
  Future<ProfileModel?> getProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      // 로그인이 되어있지 않으면 프로필이 없으므로 null을 반환합니다.
      return null;
    }

    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single(); // ⭐️ 단일 행을 가져옵니다.

      // ⭐️ 2. Profile -> ProfileModel로 수정합니다.
      return ProfileModel.fromJson(response);
    } catch (e) {
      // Supabase PostgrestError 등을 더 구체적으로 처리할 수 있습니다.
      print('--- 🚨 프로필 정보 가져오기 실패 🚨 ---');
      print(e);
      return null;
    }
  }

  /// 사용자의 프로필 정보를 업데이트합니다. (레벨 2 회원가입, 마이페이지 수정 등에서 사용)
  ///
  /// [nickname], [fullName], [phoneNumber], [address] 중 변경이 필요한 값만 전달합니다.
  Future<void> updateProfile({
    String? nickname,
    String? fullName,
    String? phoneNumber,
    String? address,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('프로필을 업데이트하려면 로그인이 필요합니다.');

    // ⭐️ 3. 업데이트할 데이터만 Map으로 구성합니다.
    final Map<String, dynamic> updates = {};
    if (nickname != null) updates['nickname'] = nickname;
    if (fullName != null) updates['full_name'] = fullName;
    if (phoneNumber != null) updates['phone_number'] = phoneNumber;
    if (address != null) updates['address'] = address;
    
    // 업데이트할 내용이 있을 때만 DB에 요청합니다.
    if (updates.isNotEmpty) {
      await _client.from('profiles').update(updates).eq('id', userId);
    }
  }
}