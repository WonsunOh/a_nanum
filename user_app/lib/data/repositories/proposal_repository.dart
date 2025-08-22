import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProposalRepository {
  final _client = Supabase.instance.client;

  /// ## 새로운 공구 신청 제출
  Future<void> submitProposal({
    required String productName,
    String? productUrl,
    String? reason,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('로그인이 필요합니다.');

    try {
      await _client.from('proposals').insert({
        'proposer_id': userId,
        'product_name': productName,
        'product_url': productUrl,
        'reason': reason,
      });
    } catch (e) {
      print('공구 신청 제출 에러: $e');
      rethrow;
    }
  }
}

final proposalRepositoryProvider = Provider((ref) => ProposalRepository());