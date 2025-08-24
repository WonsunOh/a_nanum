// user_app/lib/features/shop/viewmodel/product_detail_viewmodel.dart (새 파일)

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/product_repository.dart';

part 'product_detail_viewmodel.g.dart';

// ⭐️ autoDispose를 사용하여, 사용자가 상세 페이지를 벗어나면 메모리에서 자동으로 해제되도록 합니다.
@riverpod
Future<ProductModel> productDetail(ProductDetailRef ref, int productId) {
  final productRepository = ref.watch(productRepositoryProvider);
  return productRepository.fetchProductById(productId);
}