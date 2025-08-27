import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/reply_template_model.dart';

class ReplyTemplateRepository {
  final SupabaseClient _supabaseAdmin;

  ReplyTemplateRepository()
      : _supabaseAdmin = SupabaseClient(
          dotenv.env['SUPABASE_URL']!,
          dotenv.env['SUPABASE_SERVICE_ROLE_KEY']!,
        );

  Future<List<ReplyTemplate>> fetchAllTemplates() async {
    final response = await _supabaseAdmin.from('reply_templates').select().order('title');
    return (response as List).map((data) => ReplyTemplate.fromJson(data)).toList();
  }

  Future<void> createTemplate({required String title, required String content}) async {
    await _supabaseAdmin.from('reply_templates').insert({'title': title, 'content': content});
  }

  Future<void> updateTemplate({required int id, required String title, required String content}) async {
    await _supabaseAdmin.from('reply_templates').update({'title': title, 'content': content}).eq('id', id);
  }

  Future<void> deleteTemplate(int id) async {
    await _supabaseAdmin.from('reply_templates').delete().eq('id', id);
  }
}

final replyTemplateRepositoryProvider = Provider((ref) => ReplyTemplateRepository());