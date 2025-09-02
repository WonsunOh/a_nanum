// user_app/lib/features/shop/viewmodel/product_detail_viewmodel.dart (전체 교체)
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/product_variant_model.dart';
import '../../../data/repositories/product_repository.dart';

part 'product_detail_viewmodel.g.dart';

// ⭐️ 1. 상품 상세 페이지의 모든 데이터를 담을 상태 클래스
class ProductDetailState {
  final ProductModel product;
  final List<OptionGroup> optionGroups;
  final List<ProductVariant> variants;

  ProductDetailState({
    required this.product,
    required this.optionGroups,
    required this.variants,
  });
}

// ✅ 1단계: 기존 구조 + 에러 처리 + 성능 최적화
@riverpod
Future<ProductDetailState> productDetail(
  ProductDetailRef ref,
  int productId,
) async {
  try {
    Logger.debug('상품 상세 정보 로드 시작: $productId', 'ProductDetail');
    
    final productRepository = ref.watch(productRepositoryProvider);

    // ✅ 병렬 처리로 성능 최적화
    final results = await Future.wait([
      productRepository.fetchProductById(productId),
      productRepository.fetchProductOptionsAndVariants(productId),
    ]);

    final product = results[0] as ProductModel;
    final optionsData = results[1] as (List<OptionGroup>, List<ProductVariant>);

    Logger.info('상품 상세 정보 로드 완료: ${product.name}', 'ProductDetail');
    
    return ProductDetailState(
      product: product,
      optionGroups: optionsData.$1,
      variants: optionsData.$2,
    );
  } catch (error, stackTrace) {
    Logger.error('상품 상세 정보 로드 실패', error, stackTrace, 'ProductDetail');
    throw ErrorHandler.handleSupabaseError(error);
  }
}
