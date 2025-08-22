import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/app_user_model.dart';
import '../models/user_detail_model.dart';

class UserRepository {
  final SupabaseClient _supabaseAdmin;

  UserRepository()
      : _supabaseAdmin = SupabaseClient(
          dotenv.env['SUPABASE_URL']!,
          dotenv.env['SUPABASE_SERVICE_ROLE_KEY']!,
        );
  
  // 모든 사용자 목록을 가져옵니다.
  Future<List<AppUser>> fetchAllUsers({String? searchQuery}) async {
    try {
      final List<User> response = await _supabaseAdmin.auth.admin.listUsers();
      
      final profilesResponse = await _supabaseAdmin.from('profiles').select('id, username');
      final profilesMap = {for (var p in profilesResponse) p['id']: p['username']};

      // 💡 2. 실제 사용자 목록은 response 객체 안의 'users' 리스트에 들어있습니다.
      List<AppUser> users = response.map((user) {
        return AppUser.fromUser(
          user,
          username: profilesMap[user.id],
        );
      }).toList();

      if (searchQuery != null && searchQuery.isNotEmpty) {
        users = users.where((user) {
          final query = searchQuery.toLowerCase();
          return user.email.toLowerCase().contains(query) ||
                 user.username.toLowerCase().contains(query);
        }).toList();
      }
      
      return users;
    } catch (e) {
      print('Error fetching users: $e');
      rethrow;
    }
  }


  // 💡 사용자 상세 정보를 가져오는 메소드
  Future<UserDetail> fetchUserDetails(String userId) async {
    try {
      final response = await _supabaseAdmin.rpc(
        'get_user_details',
        params: {'p_user_id': userId},
      ).single();
      return UserDetail.fromJson(response);
    } catch (e) {
      print('Error fetching user details: $e');
      rethrow;
    }
  }

  // 💡 사용자 레벨을 수정하는 메소드
  Future<void> updateUserLevel(String userId, int newLevel) async {
    try {
      await _supabaseAdmin
          .from('profiles')
          .update({'level': newLevel})
          .eq('id', userId);
    } catch (e) {
      print('Error updating user level: $e');
      rethrow;
    }
  }
}

final userRepositoryProvider = Provider((ref) => UserRepository());