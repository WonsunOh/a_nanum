import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/repositories/product_repository.dart';

final categoriesProvider = StreamProvider.autoDispose<List<Category>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchAllCategories();
});

final productViewModelProvider = StateNotifierProvider.autoDispose<ProductViewModel, AsyncValue<List<Product>>>((ref) {
  return ProductViewModel(ref.read(productRepositoryProvider));
});

class ProductViewModel extends StateNotifier<AsyncValue<List<Product>>> {
  final ProductRepository _repository;

  ProductViewModel(this._repository) : super(const AsyncValue.loading()) {
    fetchAllProducts();
  }

  Future<void> fetchAllProducts() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.fetchAllProducts());
  }

  Future<bool> createProduct({
    required String name,
    required int totalPrice,
    required XFile image,
    String? description,
    int? categoryId,
    String? externalProductId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final imageBytes = await image.readAsBytes();
      final imageUrl = await _repository.uploadProductImage(imageBytes, image.name);
      await _repository.createProduct(
        name: name,
        totalPrice: totalPrice,
        description: description,
        imageUrl: imageUrl,
        categoryId: categoryId,
        externalProductId: externalProductId,
      );
      await fetchAllProducts();
      return true;
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      return false;
    }
  }

  Future<bool> updateProduct({
    required Product existingProduct,
    required String name,
    required int totalPrice,
    String? description,
    int? categoryId,
    String? externalProductId,
    XFile? image,
  }) async {
    state = const AsyncValue.loading();
    try {
      String? imageUrl = existingProduct.imageUrl;
      if (image != null) {
        final imageBytes = await image.readAsBytes();
        imageUrl = await _repository.uploadProductImage(imageBytes, image.name);
      }
      await _repository.updateProduct(
        id: existingProduct.id,
        name: name,
        totalPrice: totalPrice,
        description: description,
        imageUrl: imageUrl,
        categoryId: categoryId,
        externalProductId: externalProductId,
      );
      await fetchAllProducts();
      return true;
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      return false;
    }
  }

  Future<void> deleteProduct(int productId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteProduct(productId);
      await fetchAllProducts();
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}