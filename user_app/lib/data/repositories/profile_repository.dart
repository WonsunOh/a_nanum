// user_app/lib/data/repositories/profile_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(Supabase.instance.client);
});

class ProfileRepository {
  final SupabaseClient _client;
  ProfileRepository(this._client);

  // getProfile 메서드에 디버깅 로그 추가
Future<ProfileModel?> getProfile() async {
  final userId = _client.auth.currentUser?.id;
  if (userId == null) {
    return null;
  }

  try {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    print('🔍 Profile 데이터 확인:');
    print('- Phone Number: ${response['phone']}');  // phone 키로 확인
    print('- Full Name: ${response['full_name']}');
    print('- Raw Response: $response');

    return ProfileModel.fromJson(response);
  } catch (e) {
    print('--- 🚨 프로필 정보 가져오기 실패 🚨 ---');
    print(e);
    return null;
  }
}

  /// 프로필 정보를 업데이트합니다 (우편번호 포함)
  Future<void> updateProfile({
    String? nickname,
    String? fullName,
    String? phoneNumber,
    String? address,
    String? postcode, // ✅ 우편번호 파라미터 추가
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('프로필을 업데이트하려면 로그인이 필요합니다.');

    final Map<String, dynamic> updates = {};
    if (nickname != null) updates['nickname'] = nickname;
    if (fullName != null) updates['full_name'] = fullName;
    if (phoneNumber != null) updates['phone'] = phoneNumber;
    if (address != null) updates['address'] = address;
    if (postcode != null) updates['postcode'] = postcode; // ✅ 우편번호 업데이트
    
    if (updates.isNotEmpty) {
      await _client.from('profiles').update(updates).eq('id', userId);
    }
  }

  /// 레벨업과 함께 프로필 업데이트 (레벨 2로 승급)
  Future<void> updateProfileAndLevel({
    String? nickname,
    String? fullName,
    String? phoneNumber,
    String? address,
    String? postcode,
    int? newLevel,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('프로필을 업데이트하려면 로그인이 필요합니다.');

    final Map<String, dynamic> updates = {};
    if (nickname != null) updates['nickname'] = nickname;
    if (fullName != null) updates['full_name'] = fullName;
    if (phoneNumber != null) updates['phone'] = phoneNumber;
    if (address != null) updates['address'] = address;
    if (postcode != null) updates['postcode'] = postcode;
    if (newLevel != null) updates['level'] = newLevel; // ✅ 레벨 업데이트
    
    if (updates.isNotEmpty) {
      await _client.from('profiles').update(updates).eq('id', userId);
    }
  }
}