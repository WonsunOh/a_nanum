import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/managed_group_buy_model.dart';

class GroupBuyAdminRepository {
  final SupabaseClient _supabaseAdmin;

  GroupBuyAdminRepository()
      : _supabaseAdmin = SupabaseClient(
          dotenv.env['SUPABASE_URL']!,
          dotenv.env['SUPABASE_SERVICE_ROLE_KEY']!,
        );

  /// ## 개설된 모든 공동구매 목록 조회
  /// group_buys 테이블을 기준으로 products와 profiles 테이블을 JOIN하여 관련 정보를 함께 가져옵니다.
  Future<List<ManagedGroupBuy>> fetchAllGroupBuys() async {
    try {
      final response = await _supabaseAdmin
          .from('group_buys')
          .select('*, products(name), profiles(username)')
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((data) => ManagedGroupBuy.fromJson(data))
          .toList();
    } catch (e) {
      print('Error fetching all group buys: $e');
      rethrow;
    }
  }

  // TODO: 공구 상태를 강제로 변경하는 등의 관리자용 메소드 추가 가능
  // Future<void> updateGroupBuyStatus(int id, String newStatus) async { ... }
}

/// ## GroupBuy Admin Repository Provider
final groupBuyAdminRepositoryProvider = Provider((ref) => GroupBuyAdminRepository());