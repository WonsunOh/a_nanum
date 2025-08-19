import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final SupabaseClient _supabaseAdmin;

  CategoryRepository()
      : _supabaseAdmin = SupabaseClient(
          dotenv.env['SUPABASE_URL']!,
          dotenv.env['SUPABASE_SERVICE_ROLE_KEY']!,
        );

  Stream<List<Category>> watchAllCategories() {
    return _supabaseAdmin
        .from('categories')
        .stream(primaryKey: ['id'])
        .order('parent_id', ascending: true)
        .map((listOfMaps) =>
            listOfMaps.map((map) => Category.fromJson(map)).toList());
  }

  Future<void> createCategory({required String name, int? parentId}) async {
    await _supabaseAdmin.from('categories').insert({'name': name, 'parent_id': parentId});
  }

  Future<void> updateCategory({required int id, required String name, int? parentId}) async {
    await _supabaseAdmin.from('categories').update({'name': name, 'parent_id': parentId}).eq('id', id);
  }

  Future<void> deleteCategory(int categoryId) async {
    await _supabaseAdmin.from('categories').delete().eq('id', categoryId);
  }
}

final categoryRepositoryProvider = Provider((ref) => CategoryRepository());