// admin_web/lib/features/shop_management/categories/viewmodel/category_viewmodel.dart (전체 교체)

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/repositories/category_repository.dart';

part 'category_viewmodel.g.dart';

@Riverpod(keepAlive: true)
class Categories extends _$Categories {
  late final CategoryRepository _repository;

  @override
  Future<List<CategoryModel>> build() async {
    _repository = ref.watch(categoryRepositoryProvider);
    // ⭐️ 평평한 리스트를 가져와서 계층 구조로 변환하는 함수를 호출합니다.
    return _buildCategoryTree();
  }

  // ⭐️ 평평한 카테고리 리스트를 계층 구조로 변환하는 핵심 로직
  Future<List<CategoryModel>> _buildCategoryTree() async {
    final allCategories = await _repository.fetchCategories();
    
    // id를 키로 하는 맵을 만들어 빠른 조회를 가능하게 합니다.
    final Map<int, CategoryModel> categoryMap = {
      for (var cat in allCategories) cat.id: cat
    };
    
    // 최상위 카테고리들을 담을 리스트
    final List<CategoryModel> rootCategories = [];

    for (var category in allCategories) {
      // 부모 ID가 없는 카테고리는 최상위(root) 카테고리입니다.
      if (category.parentId == null) {
        rootCategories.add(category);
      } else {
        // 부모 ID가 있다면, 부모 카테고리의 children 리스트에 자신을 추가합니다.
        final parent = categoryMap[category.parentId];
        if (parent != null) {
          parent.children.add(category);
        }
      }
    }
    return rootCategories;
  }

  // 카테고리 추가
  Future<void> addCategory({required String name, int? parentId}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.addCategory(name: name, parentId: parentId);
      return _buildCategoryTree(); // 목록 새로고침
    });
  }

  // 카테고리 수정
  Future<void> updateCategory(CategoryModel category) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.updateCategory(category);
      return _buildCategoryTree(); // 목록 새로고침
    });
  }

  // 카테고리 삭제
  Future<void> deleteCategory(int categoryId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteCategory(categoryId);
      return _buildCategoryTree(); // 목록 새로고침
    });
  }
}