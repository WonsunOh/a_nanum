// user_app/lib/data/repositories/level_upgrade_repository.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/level_upgrade_request_model.dart';

class LevelUpgradeRepository {
  final _client = Supabase.instance.client;

  /// 레벨 업그레이드 신청 제출
  Future<void> submitUpgradeRequest({
    required int currentLevel,
    required int requestedLevel,
    required String reason,
    String? additionalInfo,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('로그인이 필요합니다.');

    try {
      await _client.from('level_upgrade_requests').insert({
        'user_id': userId,
        'current_level': currentLevel,
        'requested_level': requestedLevel,
        'reason': reason,
        'additional_info': additionalInfo,
      });
    } catch (e) {
      rethrow;
    }
  }

  /// 현재 사용자의 레벨 업그레이드 신청 기록 조회
  Future<List<LevelUpgradeRequest>> getUserUpgradeRequests() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('로그인이 필요합니다.');

    try {
      final response = await _client
          .from('level_upgrade_requests')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => LevelUpgradeRequest.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// 진행 중인 신청이 있는지 확인
  Future<bool> hasPendingRequest() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      final response = await _client
          .from('level_upgrade_requests')
          .select('id')
          .eq('user_id', userId)
          .eq('status', 'pending')
          .maybeSingle();

      return response != null;
    } catch (e) {
      debugPrint('진행 중인 신청 확인 에러: $e');
      return false;
    }
  }
}

final levelUpgradeRepositoryProvider = Provider((ref) => LevelUpgradeRepository());