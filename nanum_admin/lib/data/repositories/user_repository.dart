import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_user_model.dart';
import '../models/user_detail_model.dart';

class UserRepository {
  // 생성자에서 SupabaseClient를 직접 받도록 수정
  final SupabaseClient _client;
  UserRepository(this._client);

  // 모든 사용자 목록을 가져옵니다.
  Future<List<AppUser>> fetchAllUsers({String? searchQuery}) async {
    try {
      // 이제 관리자 클라이언트가 아닌, 안전한 전역 클라이언트를 사용합니다.
      // 이 API는 관리자 권한이 필요하므로, Supabase 대시보드에서 RLS 정책으로 제어해야 합니다.
      final List<User> response = await _client.auth.admin.listUsers();
      
      final profilesResponse = await _client.from('profiles').select('id, username, level');
      final profilesMap = {
        for (var p in profilesResponse)
          p['id']: {'username': p['username'], 'level': p['level']}
      };

      List<AppUser> users = response.map((user) {
        final userProfile = profilesMap[user.id];
        return AppUser.fromUser(
          user,
          username: userProfile?['username'],
          level: userProfile?['level'],
        );
      }).toList();

      if (searchQuery != null && searchQuery.isNotEmpty) {
        users = users.where((user) {
          final query = searchQuery.toLowerCase();
          // 💡 버그 수정: user.username이 아닌, profiles에서 가져온 username으로 검색
          final username = user.username.toLowerCase() ?? '';
          return user.email.toLowerCase().contains(query) ||
                 username.contains(query);
        }).toList();
      }
      
      return users;
    } catch (e) {
      debugPrint('Error fetching users: $e');
      rethrow;
    }
  }

  // 사용자 상세 정보를 가져오는 메소드
  Future<UserDetailModel> fetchUserDetails(String userId) async {
    try {
      final response = await _client.rpc(
        'get_user_details',
        params: {'p_user_id': userId},
      ).single();
      return UserDetailModel.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching user details: $e');
      rethrow;
    }
  }

  // 사용자 레벨을 수정하는 메소드
  Future<void> updateUserLevel(String userId, int newLevel) async {
    try {
      await _client
          .from('profiles')
          .update({'level': newLevel})
          .eq('id', userId);
    } catch (e) {
      debugPrint('Error updating user level: $e');
      rethrow;
    }
  }
}

final userRepositoryProvider = Provider((ref) {
  // main.dart에서 초기화된 전역 클라이언트를 주입합니다.
  return UserRepository(Supabase.instance.client);
});