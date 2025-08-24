// admin_web/lib/features/shop_management/products/viewmodel/product_viewmodel.dart (전체 교체)

// ⭐️ 이 import 구문이 누락되어 있었습니다.
import 'package:image_picker/image_picker.dart';
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
    String? description,
    required int price,
    required int stockQuantity,
    required int categoryId,
    required bool isDisplayed,
    String? productCode,
    String? relatedProductCode,
    XFile? imageFile,
  }) async {
    final repo = ref.read(productRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      String? imageUrl;
      // ⭐️ 이미지 파일이 있다면 먼저 업로드합니다.
      if (imageFile != null) {
        final imageBytes = await imageFile.readAsBytes();
        imageUrl = await repo.uploadImage(imageBytes, imageFile.name);
      }
      await repo.addProduct(
        name: name,
        description: description,
        price: price,
        stockQuantity: stockQuantity,
        categoryId: categoryId,
        isDisplayed: isDisplayed,
        productCode: productCode,
        relatedProductCode: relatedProductCode,
        imageUrl: imageUrl,
      );
      return repo.fetchProducts();
    });
  }

  Future<void> updateProduct(ProductModel productToUpdate, {XFile? newImageFile}) async {
  final repo = ref.read(productRepositoryProvider);
  state = const AsyncValue.loading();
  state = await AsyncValue.guard(() async {
    ProductModel finalProduct = productToUpdate;

    // ⭐️ 새로운 이미지 파일이 있다면, 업로드하고 URL을 교체합니다.
    if (newImageFile != null) {
      final imageBytes = await newImageFile.readAsBytes();
      final imageUrl = await repo.uploadImage(imageBytes, newImageFile.name);
      
      // ⭐️ 업로드된 URL로 최종 상품 데이터를 업데이트합니다.
      finalProduct = productToUpdate.copyWith(imageUrl: imageUrl);
    }
    
    // ⭐️ 모든 변경사항이 적용된 최종본을 저장합니다.
    await repo.updateProduct(finalProduct);
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