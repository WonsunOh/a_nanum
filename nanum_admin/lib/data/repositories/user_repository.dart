import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_user_model.dart';
import '../models/user_detail_model.dart';

class UserRepository {
  final SupabaseClient _client;
  UserRepository(this._client);

  // ✅ Admin API 대신 뷰를 사용하여 모든 사용자 목록을 가져옵니다
  Future<List<AppUser>> fetchAllUsers({String? searchQuery}) async {
    try {
      // 🔧 admin.listUsers() 대신 public.admin_users 뷰를 사용
      var query = _client.from('admin_users').select('*');
      
      // 검색 쿼리가 있으면 필터링 추가
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
          'email.ilike.%$searchQuery%,username.ilike.%$searchQuery%'
        );
      }
      
      final response = await query;
      
      // 응답 데이터를 AppUser 모델로 변환
      List<AppUser> users = response.map<AppUser>((userData) {
        return AppUser(
          id: userData['id'],
          email: userData['email'] ?? '',
          username: userData['username'] ?? userData['email'] ?? '',
          level: userData['level'] ?? 1,
          points: userData['points'] ?? 0,
          role: userData['role'] ?? 'user',
          emailConfirmedAt: userData['email_confirmed_at'] != null 
            ? DateTime.parse(userData['email_confirmed_at']) 
            : null,
          createdAt: userData['created_at'] != null 
            ? DateTime.parse(userData['created_at']) 
            : DateTime.now(),
          lastSignInAt: userData['last_sign_in_at'] != null 
            ? DateTime.parse(userData['last_sign_in_at']) 
            : null,
        );
      }).toList();
      
      return users;
    } catch (e) {
      debugPrint('Error fetching users: $e');
      // 권한 에러인 경우 더 구체적인 에러 메시지 제공
      if (e.toString().contains('403') || e.toString().contains('not_admin')) {
        throw Exception('관리자 권한이 필요합니다. Supabase에서 관리자 권한을 설정해주세요.');
      }
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

  // 사용자 역할을 수정하는 메소드 (새로 추가)
  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      await _client
          .from('profiles')
          .update({'role': newRole})
          .eq('id', userId);
    } catch (e) {
      debugPrint('Error updating user role: $e');
      rethrow;
    }
  }
}

final userRepositoryProvider = Provider((ref) {
  return UserRepository(Supabase.instance.client);
});