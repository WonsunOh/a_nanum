// user_app/lib/features/shop/viewmodel/category_viewmodel.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/models/category_model.dart';
import '../../../data/repositories/category_repository.dart';

part 'category_viewmodel.g.dart';

@Riverpod(keepAlive: true)
class Categories extends _$Categories {
  // ✅ late final 제거하고 getter로 변경
  CategoryRepository get _repository => ref.watch(categoryRepositoryProvider);

  @override
  Future<List<CategoryModel>> build() async {
    // ✅ 초기화 코드 제거하고 직접 호출
    return _buildCategoryTree();
  }

  Future<List<CategoryModel>> _buildCategoryTree() async {
    final allCategories = await _repository.fetchCategories();
    
    final Map<int, CategoryModel> categoryMap = {
      for (var cat in allCategories) cat.id: cat
    };
    
    final List<CategoryModel> rootCategories = [];

    for (var category in allCategories) {
      if (category.parentId == null) {
        rootCategories.add(category);
      } else {
        final parent = categoryMap[category.parentId];
        if (parent != null) {
          parent.children.add(category);
        }
      }
    }
    return rootCategories;
  }
}