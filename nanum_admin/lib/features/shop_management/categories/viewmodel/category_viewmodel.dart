// admin_web/lib/features/shop_management/categories/viewmodel/category_viewmodel.dart (전체 교체)

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/utils/logger.dart';
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

  // ✅ 1단계: 기존 기능 + 에러 처리 + 로깅
  Future<List<CategoryModel>> _buildCategoryTree() async {
    try {
      Logger.debug('카테고리 트리 구축 시작', 'Categories');
      
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
      
      Logger.info('카테고리 트리 구축 완료: ${rootCategories.length}개 루트', 'Categories');
      return rootCategories;
    } catch (error, stackTrace) {
      Logger.error('카테고리 트리 구축 실패', error, stackTrace, 'Categories');
      throw ErrorHandler.handleSupabaseError(error);
    }
  }

 Future<void> addCategory({required String name, int? parentId}) async {
    try {
      // 입력 검증
      if (name.trim().isEmpty) {
        throw const ValidationException('카테고리명을 입력해주세요.');
      }
      if (name.length > 50) {
        throw const ValidationException('카테고리명은 50자 이하여야 합니다.');
      }

      Logger.debug('카테고리 추가: $name (부모ID: $parentId)', 'Categories');
      
      state = const AsyncValue.loading();
      await _repository.addCategory(name: name, parentId: parentId);
      
      state = AsyncValue.data(await _buildCategoryTree());
      Logger.info('카테고리 추가 완료: $name', 'Categories');
    } catch (error, stackTrace) {
      Logger.error('카테고리 추가 실패', error, stackTrace, 'Categories');
      state = AsyncValue.error(ErrorHandler.handleSupabaseError(error), stackTrace);
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    try {
      Logger.debug('카테고리 수정: ${category.name}', 'Categories');
      
      state = const AsyncValue.loading();
      await _repository.updateCategory(category);
      
      state = AsyncValue.data(await _buildCategoryTree());
      Logger.info('카테고리 수정 완료', 'Categories');
    } catch (error, stackTrace) {
      Logger.error('카테고리 수정 실패', error, stackTrace, 'Categories');
      state = AsyncValue.error(ErrorHandler.handleSupabaseError(error), stackTrace);
    }
  }


   Future<void> deleteCategory(int categoryId) async {
    try {
      Logger.debug('카테고리 삭제: ID $categoryId', 'Categories');
      
      state = const AsyncValue.loading();
      await _repository.deleteCategory(categoryId);
      
      state = AsyncValue.data(await _buildCategoryTree());
      Logger.info('카테고리 삭제 완료', 'Categories');
    } catch (error, stackTrace) {
      Logger.error('카테고리 삭제 실패', error, stackTrace, 'Categories');
      state = AsyncValue.error(ErrorHandler.handleSupabaseError(error), stackTrace);
    }
  }
}