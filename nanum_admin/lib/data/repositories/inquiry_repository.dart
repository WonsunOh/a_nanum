import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/inquiry_model.dart';

class InquiryRepository {
  final SupabaseClient _client;

  InquiryRepository(this._client);
    

  Future<List<Inquiry>> fetchAllInquiries() async {
    final response = await _client
        .from('inquiries')
        .select('*, profiles(username)') // 문의자 이름을 함께 가져옴
        .order('created_at', ascending: false);
    return (response as List).map((data) => Inquiry.fromJson(data)).toList();
  }

  Future<void> submitReply({required int inquiryId, required String reply}) async {
    await _client
        .from('inquiries')
        .update({
          'reply': reply,
          'status': 'answered',
          'answered_at': DateTime.now().toIso8601String(),
        })
        .eq('id', inquiryId);
  }
}

final inquiryRepositoryProvider = Provider((ref) {
  return InquiryRepository(Supabase.instance.client);
});