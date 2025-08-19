import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/category_model.dart';
import '../../../data/repositories/category_repository.dart';

final selectedL1CategoryProvider = StateProvider.autoDispose<Category?>((ref) => null);
final selectedL2CategoryProvider = StateProvider.autoDispose<Category?>((ref) => null);

final categoryViewModelProvider = StateNotifierProvider.autoDispose<CategoryViewModel, AsyncValue<void>>((ref) {
  return CategoryViewModel(ref.read(categoryRepositoryProvider));
});

class CategoryViewModel extends StateNotifier<AsyncValue<void>> {
  final CategoryRepository _repository;
  CategoryViewModel(this._repository) : super(const AsyncValue.data(null));

  Future<void> createCategory({required String name, int? parentId}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.createCategory(name: name, parentId: parentId));
  }

  Future<void> updateCategory({required int id, required String name, int? parentId}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.updateCategory(id: id, name: name, parentId: parentId));
  }

  Future<void> deleteCategory(int categoryId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.deleteCategory(categoryId));
  }
}