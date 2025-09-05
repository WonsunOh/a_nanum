// admin_web/lib/features/shop_management/products/viewmodel/product_viewmodel.dart (전체 교체)

import 'package:flutter/foundation.dart';
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
    List<XFile>? imageFiles,
    List<OptionGroup>? optionGroups,
    List<ProductVariant>? variants,
    required int shippingFee,
    Map<String, bool>? tags,
    DateTime? discountStartDate,
    DateTime? discountEndDate,
  }) async {

   
    state = const AsyncValue.loading();
  state = await AsyncValue.guard(() async {

    
    
    // ✅ 여러 이미지 업로드 처리
    String? mainImageUrl;
    List<String> additionalImageUrls = [];
    
    if (imageFiles != null && imageFiles.isNotEmpty) {
      for (int i = 0; i < imageFiles.length; i++) {
        final imageFile = imageFiles[i];

        final imageBytes = await imageFile.readAsBytes();
        final imageUrl = await _repository.uploadImage(imageBytes, imageFile.name);

        
        if (imageUrl != null) {
          if (i == 0) {
            mainImageUrl = imageUrl; // 첫 번째는 대표 이미지
          } else {
            additionalImageUrls.add(imageUrl); // 나머지는 추가 이미지
          }
        }
      }

  
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
        imageUrl: mainImageUrl,
        additionalImages: additionalImageUrls.isNotEmpty ? additionalImageUrls : null, // ✅ 추가 이미지들 전달
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
    try {
      Logger.debug('상품 수정 시작: ${product.name}', 'ProductViewModel');
      
      state = const AsyncValue.loading();
      await _repository.updateProductDetails(product);
      // ✅ 업데이트 후 전체 목록 새로고침
      await fetchAllProducts();
      
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

 Future<void> updateProductWithOptions(
  ProductModel product, {
  List<OptionGroup>? optionGroups,
  List<ProductVariant>? variants,
  List<XFile>? imageFiles,
  List<String>? existingImageUrls,
}) async {
  state = const AsyncValue.loading();
  state = await AsyncValue.guard(() async {

    

    // 최종 이미지 URL 목록 결정
    List<String> finalImageUrls = [];
    
    // 1. existingImageUrls가 있으면 이걸 최우선으로 사용 (사용자가 수정한 순서)
    if (existingImageUrls != null && existingImageUrls.isNotEmpty) {
      finalImageUrls.addAll(existingImageUrls);
    } else {
      // 2. 없으면 기존 product의 이미지들 사용
      if (product.imageUrl != null) finalImageUrls.add(product.imageUrl!);
      if (product.additionalImages != null) finalImageUrls.addAll(product.additionalImages!);
    }

    // 3. 새로 업로드할 이미지들 추가
    if (imageFiles != null && imageFiles.isNotEmpty) {
      for (final imageFile in imageFiles) {
        final imageBytes = await imageFile.readAsBytes();
        final imageUrl = await _repository.uploadImage(imageBytes, imageFile.name);
        if (imageUrl != null) {
          finalImageUrls.add(imageUrl);
        }
      }
    }

    // 최종 이미지 구성
    String? finalMainImage = finalImageUrls.isNotEmpty ? finalImageUrls.first : null;
    List<String>? finalAdditionalImages = finalImageUrls.length > 1 
        ? finalImageUrls.skip(1).toList() 
        : null;

    
    await _repository.updateProductWithOptions(
      product.copyWith(
        imageUrl: finalMainImage,
        additionalImages: finalAdditionalImages,
      ),
      optionGroups: optionGroups ?? [],
      variants: variants ?? [],
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
      // ✅ 삭제 후 전체 목록 새로고침
      await fetchAllProducts();
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

final productVariantsProvider = FutureProvider.family<List<ProductVariant>, int>((ref, productId) async {
  final repository = ref.read(productRepositoryProvider);
  return repository.fetchVariantsByProductId(productId);
});