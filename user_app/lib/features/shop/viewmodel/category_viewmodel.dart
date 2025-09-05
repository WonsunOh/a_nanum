// user_app/lib/features/shop/viewmodel/category_viewmodel.dart (새 파일)

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/models/category_model.dart';
import '../../../data/repositories/category_repository.dart';

part 'category_viewmodel.g.dart';

@Riverpod(keepAlive: true)
class Categories extends _$Categories {
  late final CategoryRepository _repository;

  @override
  Future<List<CategoryModel>> build() async {
    _repository = ref.watch(categoryRepositoryProvider);
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