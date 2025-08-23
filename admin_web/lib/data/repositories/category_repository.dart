// admin_web/lib/data/repositories/category_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';

// Repository 인스턴스를 제공하는 Provider
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(Supabase.instance.client);
});

class CategoryRepository {
  final SupabaseClient _client;

  CategoryRepository(this._client);

  // 모든 카테고리 목록을 가져오는 기능
  Future<List<CategoryModel>> fetchCategories() async {
    final response = await _client.from('categories').select().order('name');
    return response.map((item) => CategoryModel.fromJson(item)).toList();
  }

  // TODO: 나중에 카테고리 추가/수정/삭제 기능을 여기에 추가합니다.
}