// nanum_admin/lib/features/shop_management.dart/products/viewmodel/discount_product_viewmodel.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/product_model.dart';
import '../../../../data/repositories/product_repository.dart';

final discountProductViewModelProvider = StateNotifierProvider.autoDispose<
    DiscountProductViewModel, AsyncValue<List<ProductModel>>>((ref) {
  return DiscountProductViewModel(ref.watch(productRepositoryProvider));
});

class DiscountProductViewModel extends StateNotifier<AsyncValue<List<ProductModel>>> {
  final ProductRepository _repository;
  DiscountProductViewModel(this._repository) : super(const AsyncValue.loading()) {
    fetchDiscountedProducts();
  }

  Future<void> fetchDiscountedProducts() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.fetchDiscountedProducts());
  }
// ⭐️ [해결책] 할인 리스트 수정을 위한 전용 ViewModel 메서드 추가
  Future<void> updateProductPrice({
    required int productId,
    required int price,
    int? discountPrice,
    DateTime? discountStartDate,
    DateTime? discountEndDate,
  }) async {
    // 1. UI 즉시 업데이트 (낙관적 업데이트)
    state.whenData((products) {
      final index = products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        final updatedProduct = products[index].copyWith(
          price: price,
          discountPrice: discountPrice,
          discountStartDate: discountStartDate,
          discountEndDate: discountEndDate,
        );
        
       final newList = List<ProductModel>.from(products);
        // 할인 가격이 없으면 리스트에서 제거, 있으면 정보 업데이트
        if (discountPrice == null || discountPrice <= 0) {
          newList.removeAt(index);
        } else {
          newList[index] = updatedProduct;
        }
        state = AsyncValue.data(newList);
      }
    });

    // 2. 실제 서버에 데이터 업데이트 요청
    await AsyncValue.guard(() => _repository.updateProductPrice(
          productId: productId,
          price: price,
          discountPrice: discountPrice,
          discountStartDate: discountStartDate,
          discountEndDate: discountEndDate,
        ));
  }
}