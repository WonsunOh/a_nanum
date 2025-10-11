// user_app/lib/features/order/viewmodel/order_viewmodel.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/repositories/order_repository.dart';

final orderViewModelProvider =
    StateNotifierProvider<OrderViewModel, AsyncValue<void>>((ref) {
  return OrderViewModel(ref.watch(orderRepositoryProvider));
});

class OrderViewModel extends StateNotifier<AsyncValue<void>> {
  final OrderRepository _repository;
  OrderViewModel(this._repository) : super(const AsyncValue.data(null));

  // 장바구니를 통한 주문 생성
  Future<bool> createOrder({
    required List<CartItemModel> cartItems,
    required int totalAmount,
    required int shippingFee,
    required String recipientName,
    required String recipientPhone,
    required String shippingAddress,
    String? paymentId,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.createOrder(
        cartItems: cartItems,
        totalAmount: totalAmount,
        shippingFee: shippingFee,
        recipientName: recipientName,
        recipientPhone: recipientPhone,
        shippingAddress: shippingAddress,
        paymentId: paymentId,
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      return false;
    }
  }

  // 🔥🔥🔥 추가: 바로구매를 통한 주문 생성
  Future<bool> createDirectOrder({
    required int productId,
    required int quantity,
    required int productPrice,
    required int totalAmount,
    required int shippingFee,
    required String recipientName,
    required String recipientPhone,
    required String shippingAddress,
    String? paymentId,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.createDirectOrder(
        productId: productId,
        quantity: quantity,
        productPrice: productPrice,
        totalAmount: totalAmount,
        shippingFee: shippingFee,
        recipientName: recipientName,
        recipientPhone: recipientPhone,
        shippingAddress: shippingAddress,
        paymentId: paymentId,
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      return false;
    }
  }
}
