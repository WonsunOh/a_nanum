// admin_web/lib/features/shop_management/products/viewmodel/product_viewmodel.dart (전체 교체)

import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/utils/logger.dart';
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

  // ✅ 1단계: 기존 기능 + 에러 처리 + 로깅
  Future<List<ProductModel>> _fetchProducts() async {
    try {
      Logger.debug('관리자 상품 목록 로드 시작', 'ProductViewModel');
      
      final products = await _repository.fetchProducts();
      
      Logger.info('관리자 상품 목록 로드 완료: ${products.length}개', 'ProductViewModel');
      return products;
    } catch (error, stackTrace) {
      Logger.error('관리자 상품 목록 로드 실패', error, stackTrace, 'ProductViewModel');
      throw ErrorHandler.handleSupabaseError(error);
    }
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
    try {
      // 입력 검증
      if (name.trim().isEmpty) {
        throw const ValidationException('상품명을 입력해주세요.');
      }
      if (price <= 0) {
        throw const ValidationException('가격은 0원보다 커야 합니다.');
      }
      if (stockQuantity < 0) {
        throw const ValidationException('재고는 0개 이상이어야 합니다.');
      }

      Logger.debug('상품 추가 시작: $name', 'ProductViewModel');
      
      state = const AsyncValue.loading();
      
      String? imageUrl;
      if (imageFile != null) {
        Logger.debug('이미지 업로드 시작', 'ProductViewModel');
        final imageBytes = await imageFile.readAsBytes();
        imageUrl = await _repository.uploadImage(imageBytes, imageFile.name);
        Logger.debug('이미지 업로드 완료: $imageUrl', 'ProductViewModel');
      }

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
      
      state = AsyncValue.data(await _fetchProducts());
      Logger.info('상품 추가 완료: $name', 'ProductViewModel');
    } catch (error, stackTrace) {
      Logger.error('상품 추가 실패', error, stackTrace, 'ProductViewModel');
      state = AsyncValue.error(ErrorHandler.handleSupabaseError(error), stackTrace);
    }
  }

  // ⭐️ 1. 상품의 '기본 정보'만 업데이트하는 메서드 (목록의 스위치에서 사용)
  Future<void> updateProductDetails(ProductModel product) async {
    try {
      Logger.debug('상품 수정 시작: ${product.name}', 'ProductViewModel');
      
      state = const AsyncValue.loading();
      await _repository.updateProductDetails(product);
      
      state = AsyncValue.data(await _fetchProducts());
      Logger.info('상품 수정 완료', 'ProductViewModel');
    } catch (error, stackTrace) {
      Logger.error('상품 수정 실패', error, stackTrace, 'ProductViewModel');
      state = AsyncValue.error(ErrorHandler.handleSupabaseError(error), stackTrace);
    }
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
    try {
      Logger.debug('상품 삭제 시작: ID $productId', 'ProductViewModel');
      
      state = const AsyncValue.loading();
      await _repository.deleteProduct(productId);
      
      state = AsyncValue.data(await _fetchProducts());
      Logger.info('상품 삭제 완료', 'ProductViewModel');
    } catch (error, stackTrace) {
      Logger.error('상품 삭제 실패', error, stackTrace, 'ProductViewModel');
      state = AsyncValue.error(ErrorHandler.handleSupabaseError(error), stackTrace);
    }
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