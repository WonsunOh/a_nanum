// user_app/lib/features/shop/viewmodel/product_viewmodel.dart (전체 교체)

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/product_repository.dart';

part 'product_viewmodel.g.dart';

@riverpod
class ProductViewModel extends _$ProductViewModel {
  @override
  Future<List<ProductModel>> build() async {
    final repository = ref.watch(productRepositoryProvider);
    return repository.fetchProducts();
  }

  // 상품 검색
  Future<void> searchProducts(String query) async {
    if (query.trim().isEmpty) {
      // 검색어가 빈 경우 전체 상품 로드
      await fetchAllProducts();
      return;
    }

    state = const AsyncValue.loading();
    final repository = ref.read(productRepositoryProvider);
    state = await AsyncValue.guard(() => repository.searchProducts(query));
  }

  // 전체 상품 다시 로드
  Future<void> fetchAllProducts() async {
    state = const AsyncValue.loading();
    final repository = ref.read(productRepositoryProvider);
    state = await AsyncValue.guard(() => repository.fetchProducts());
  }

  // 카테고리별 상품 조회
  Future<void> fetchProductsByCategory(int categoryId) async {
    state = const AsyncValue.loading();
    final repository = ref.read(productRepositoryProvider);
    state = await AsyncValue.guard(() => repository.fetchProductsByCategory(categoryId));
  }

  // ✅ 카테고리 계층구조를 고려한 상품 조회 (하위 카테고리 포함)
  Future<void> fetchProductsByCategoryHierarchy(List<int> categoryIds) async {
    state = const AsyncValue.loading();
    final repository = ref.read(productRepositoryProvider);
    state = await AsyncValue.guard(() => repository.fetchProductsByCategoryHierarchy(categoryIds));
  }
}