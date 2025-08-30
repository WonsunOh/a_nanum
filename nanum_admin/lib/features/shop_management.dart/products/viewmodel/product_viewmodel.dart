// admin_web/lib/features/shop_management/products/viewmodel/product_viewmodel.dart (전체 교체)

// ⭐️ 이 import 구문이 누락되어 있었습니다.
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../data/models/product_model.dart';
import '../../../../data/models/product_variant_model.dart';
import '../../../../data/repositories/product_repository.dart';

part 'product_viewmodel.g.dart';

@riverpod
class ProductViewModel extends _$ProductViewModel {
  late final ProductRepository _repository;
  @override
  Future<List<ProductModel>> build() {
    _repository = ref.watch(productRepositoryProvider);
    return _repository.fetchProducts();
  }

  Future<void> addProduct({
    required String name,
    String? description,
    required int price,
    int? discountPrice,
    required int stockQuantity,
    required int categoryId,
    required bool isDisplayed,
    required bool isSoldOut,
    String? productCode,
    String? relatedProductCode,
    XFile? imageFile,
    List<OptionGroup>? optionGroups,
    List<ProductVariant>? variants,
    required int shippingFee,
    Map<String, bool>? tags,
    DateTime? discountStartDate,
    DateTime? discountEndDate,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      String? imageUrl;
      // ⭐️ 이미지 파일이 있다면 먼저 업로드합니다.
      if (imageFile != null) {
        final imageBytes = await imageFile.readAsBytes();
        imageUrl = await _repository.uploadImage(imageBytes, imageFile.name);
      }

      // ⭐️ [데이터 추적 2단계] ViewModel에서 Repository로 데이터를 보내기 직전 값 확인
      debugPrint('--- [VIEWMODEL] Calling addProduct in Repository ---');
      debugPrint('Discount Start Date: $discountStartDate');
      debugPrint('Discount End Date: $discountEndDate');
      debugPrint('----------------------------------------------------');
      await _repository.addProduct(
        name: name,
        description: description,
        price: price,
        discountPrice: discountPrice,
        stockQuantity: stockQuantity,
        categoryId: categoryId,
        isDisplayed: isDisplayed,
        isSoldOut: isSoldOut,
        productCode: productCode,
        relatedProductCode: relatedProductCode,
        imageUrl: imageUrl,
        optionGroups: optionGroups,
        variants: variants,
        shippingFee: shippingFee,
        tags: tags,
        discountStartDate: discountStartDate,
        discountEndDate: discountEndDate,
      );
      return _repository.fetchProducts();
    });
  }

  // ⭐️ 1. 상품의 '기본 정보'만 업데이트하는 메서드 (목록의 스위치에서 사용)
  Future<void> updateProductDetails(ProductModel product) async {
    // 전체 목록을 로딩 상태로 바꾸지 않고, 개별 항목만 업데이트되도록 UI를 최적화
    state = await AsyncValue.guard(() async {
      await _repository.updateProductDetails(product);
      return _repository.fetchProducts();
    });
  }

  // ⭐️ 가격 정보만 업데이트하는 메서드 추가
  Future<void> updateProductPrice({
    required int productId,
    required int price,
    int? discountPrice,
    DateTime? discountStartDate,
    DateTime? discountEndDate,
  }) async {
    // 낙관적 업데이트: UI를 먼저 변경
    state.whenData((products) {
      final index = products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        final updatedProduct = products[index].copyWith(
          price: price,
          discountPrice: discountPrice,
          discountStartDate: discountStartDate,
          discountEndDate: discountEndDate,
        );
        products[index] = updatedProduct;
        state = AsyncValue.data(List.from(products));

        state = AsyncValue.data([
          ...products.sublist(0, index),
          updatedProduct,
          ...products.sublist(index + 1),
        ]);
      }
    });

    // 서버에 업데이트 요청
    await AsyncValue.guard(
      () => _repository.updateProductPrice(
        productId: productId,
        price: price,
        discountPrice: discountPrice,
        discountStartDate: discountStartDate,
        discountEndDate: discountEndDate,
      ),
    );
  }

  // ⭐️ 2. 상품 정보와 '옵션'을 모두 업데이트하는 메서드 (등록/수정 페이지에서 사용)
  Future<void> updateProductWithOptions(
    ProductModel product, {
    List<OptionGroup>? optionGroups, // ⭐️ Nullable로 변경
    List<ProductVariant>? variants, // ⭐️ Nullable로 변경
    XFile? newImageFile,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      String? imageUrl = product.imageUrl;
      if (newImageFile != null) {
        final imageBytes = await newImageFile.readAsBytes();
        imageUrl = await _repository.uploadImage(imageBytes, newImageFile.name);
      }

      final finalProduct = product.copyWith(imageUrl: imageUrl);
      await _repository.updateProductWithOptions(
        finalProduct,
        optionGroups: optionGroups,
        variants: variants,
      );
      return _repository.fetchProducts();
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

  // ⭐️ 검색을 수행하는 메서드 추가
  Future<void> searchProducts(String query) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.searchProducts(query));
  }

  // ⭐️ 전체 목록을 다시 불러오는 메서드 (검색 해제 시 사용)
  Future<void> fetchAllProducts() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.fetchProducts());
  }
}