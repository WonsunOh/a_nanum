// admin_web/lib/data/repositories/category_repository.dart (전체 교체)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/category_model.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(Supabase.instance.client);
});

class CategoryRepository {
  final SupabaseClient _client;
  CategoryRepository(this._client);

  // 모든 카테고리 목록을 가져옵니다. (정렬 순서가 중요합니다)
  Future<List<CategoryModel>> fetchCategories() async {
    final response = await _client.from('categories').select().order('id');
    return response.map((item) => CategoryModel.fromJson(item)).toList();
  }

  // 카테고리 추가
  Future<void> addCategory({required String name, int? parentId}) async {
    await _client.from('categories').insert({'name': name, 'parent_id': parentId});
  }

  // 카테고리 수정
  Future<void> updateCategory(CategoryModel category) async {
    await _client
        .from('categories')
        .update(category.toJson())
        .eq('id', category.id);
  }

  // 카테고리 삭제
  Future<void> deleteCategory(int categoryId) async {
    await _client.from('categories').delete().eq('id', categoryId);
  }
}