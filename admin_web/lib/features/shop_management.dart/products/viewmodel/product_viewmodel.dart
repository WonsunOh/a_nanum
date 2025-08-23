// admin_web/lib/features/shop_management/products/viewmodel/product_viewmodel.dart (전체 교체)

// ⭐️ 이 import 구문이 누락되어 있었습니다.
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../data/models/product_model.dart';
import '../../../../data/repositories/product_repository.dart';

part 'product_viewmodel.g.dart';

@riverpod
class ProductViewModel extends _$ProductViewModel {
  @override
  Future<List<ProductModel>> build() {
    return ref.watch(productRepositoryProvider).fetchProducts();
  }

  Future<void> addProduct({
    required String name,
    required String description,
    required int price,
    required int stockQuantity,
    required int categoryId,
    required bool isDisplayed,
    String? imageUrl,
  }) async {
    final repo = ref.read(productRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repo.addProduct(
        name: name,
        description: description,
        price: price,
        stockQuantity: stockQuantity,
        categoryId: categoryId,
        isDisplayed: isDisplayed,
        imageUrl: imageUrl,
      );
      return repo.fetchProducts();
    });
  }

  Future<void> updateProduct(ProductModel product) async {
    final repo = ref.read(productRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repo.updateProduct(product);
      return repo.fetchProducts();
    });
  }

  Future<void> deleteProduct(int productId) async {
    final repo = ref.read(productRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repo.deleteProduct(productId);
      return repo.fetchProducts();
    });
  }
}