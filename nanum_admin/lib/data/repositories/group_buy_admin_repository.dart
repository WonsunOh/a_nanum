import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/managed_group_buy_model.dart';

class GroupBuyAdminRepository {
  final SupabaseClient _client;

  GroupBuyAdminRepository(this._client);
      

  /// ## 개설된 모든 공동구매 목록 조회
  /// group_buys 테이블을 기준으로 products와 profiles 테이블을 JOIN하여 관련 정보를 함께 가져옵니다.
  Future<List<ManagedGroupBuy>> fetchAllGroupBuys() async {
    try {
      final response = await _client
          .from('group_buys')
          .select('*, products(name), profiles(username)')
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((data) => ManagedGroupBuy.fromJson(data))
          .toList();
    } catch (e) {
      debugPrint('Error fetching all group buys: $e');
      rethrow;
    }
  }
// 💡 공구 상태를 수정하는 메소드
  Future<void> updateGroupBuyStatus(int id, String newStatus) async {
    await _client.from('group_buys').update({'status': newStatus}).eq('id', id);
  }

  // 💡 공구를 삭제하는 메소드
  Future<void> deleteGroupBuy(int id) async {
    await _client.from('group_buys').delete().eq('id', id);
  }
  
}

/// ## GroupBuy Admin Repository Provider
final groupBuyAdminRepositoryProvider = Provider((ref) => GroupBuyAdminRepository(Supabase.instance.client));