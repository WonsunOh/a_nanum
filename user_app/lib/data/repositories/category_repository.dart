// user_app/lib/data/repositories/category_repository.dart (새 파일)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(Supabase.instance.client);
});

class CategoryRepository {
  final SupabaseClient _client;
  CategoryRepository(this._client);

  Future<List<CategoryModel>> fetchCategories() async {
    final response = await _client
        .from('categories')
        .select()
        .order('id');
    
    return response.map((item) => CategoryModel.fromJson(item)).toList();
  }
}