// user_app/lib/features/shop/viewmodel/product_detail_viewmodel.dart (전체 교체)
import 'package:riverpod_annotation/riverpod_annotation.dart';
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

// ⭐️ 2. Provider가 ProductModel 대신 ProductDetailState를 반환하도록 변경
@riverpod
Future<ProductDetailState> productDetail(
  ProductDetailRef ref,
  int productId,
) async {
  final productRepository = ref.watch(productRepositoryProvider);

  // ⭐️ 3. 상품 정보와 옵션 정보를 병렬로 동시에 불러옵니다.
  final results = await Future.wait([
    productRepository.fetchProductById(productId),
    productRepository.fetchProductOptionsAndVariants(productId),
  ]);

  final product = results[0] as ProductModel;
  final optionsData = results[1] as (List<OptionGroup>, List<ProductVariant>);

  return ProductDetailState(
    product: product,
    optionGroups: optionsData.$1,
    variants: optionsData.$2,
  );
}
