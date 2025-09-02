import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/errors/error_handler.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/product_repository.dart';

part 'shop_viewmodel.g.dart';

@riverpod
Future<List<ProductModel>> shopViewModel(Ref ref) async {
  try {
    Logger.debug('상품 목록 로드 시작', 'ShopViewModel');
    
    final productRepository = ref.watch(productRepositoryProvider);
    final products = await productRepository.fetchProducts();
    
    Logger.info('상품 목록 로드 완료: ${products.length}개', 'ShopViewModel');
    return products;
  } catch (error, stackTrace) {
    Logger.error('상품 목록 로드 실패', error, stackTrace, 'ShopViewModel');
    
    // 사용자 친화적인 에러로 변환
    final appError = ErrorHandler.handleSupabaseError(error);
    throw appError;
  }
}

// // ✅ 새로운 기능들을 별도 Provider로 추가 (기존 코드 영향 없음)
// @riverpod
// Future<List<ProductModel>> searchProducts(Ref ref, String keyword) async {
//   if (keyword.trim().isEmpty) {
//     // 검색어가 비어있으면 전체 상품 반환
//     return ref.watch(shopViewModelProvider.future);
//   }

//   try {
//     Logger.debug('상품 검색 시작: $keyword', 'SearchProducts');
    
//     final productRepository = ref.watch(productRepositoryProvider);
//     final results = await productRepository.searchProducts(keyword: keyword);
    
//     Logger.info('검색 결과: ${results.length}개', 'SearchProducts');
//     return results;
//   } catch (error, stackTrace) {
//     Logger.error('상품 검색 실패', error, stackTrace, 'SearchProducts');
//     throw ErrorHandler.handleSupabaseError(error);
//   }
// }

// @riverpod
// Future<List<ProductModel>> productsByCategory(Ref ref, int? categoryId) async {
//   try {
//     Logger.debug('카테고리별 상품 로드: $categoryId', 'ProductsByCategory');
    
//     final productRepository = ref.watch(productRepositoryProvider);
//     final products = await productRepository.fetchProductsByCategory(
//       categoryId: categoryId,
//     );
    
//     Logger.info('카테고리 상품 로드 완료: ${products.length}개', 'ProductsByCategory');
//     return products;
//   } catch (error, stackTrace) {
//     Logger.error('카테고리 상품 로드 실패', error, stackTrace, 'ProductsByCategory');
//     throw ErrorHandler.handleSupabaseError(error);
//   }
// }

// ✅ View에서 사용할 때는 기존과 동일하게 사용
// ref.watch(shopViewModelProvider) - 기존 방식 그대로
// ref.watch(searchProductsProvider('검색어')) - 새로운 검색 기능
// ref.watch(productsByCategoryProvider(1)) - 새로운 카테고리 필터