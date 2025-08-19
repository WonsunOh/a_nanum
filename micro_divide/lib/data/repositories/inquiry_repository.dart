import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class InquiryRepository {
  final _client = Supabase.instance.client;

  /// ## 새로운 문의 제출
  /// 사용자가 작성한 제목과 내용을 DB에 저장합니다.
  Future<void> submitInquiry({required String title, required String content}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      // 이 경우는 보통 라우터 리디렉션으로 처리되지만, 만약을 위한 방어 코드입니다.
      throw Exception('로그인이 필요합니다.');
    }

    try {
      await _client.from('inquiries').insert({
        'author_id': userId,
        'title': title,
        'content': content,
      });
    } catch (e) {
      print('문의 제출 에러: $e');
      rethrow;
    }
  }
}

/// ## Inquiry Repository Provider
final inquiryRepositoryProvider = Provider((ref) => InquiryRepository());