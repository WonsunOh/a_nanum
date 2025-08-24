// user_app/lib/features/order/viewmodel/order_viewmodel.dart (전체 코드)

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/repositories/order_repository.dart';
import '../../cart/viewmodel/cart_viewmodel.dart';

part 'order_viewmodel.g.dart';

@riverpod
class OrderViewModel extends _$OrderViewModel {
  late final OrderRepository _repository;

  @override
  Future<void> build() async {
    // Provider가 처음 생성될 때 Repository를 초기화합니다.
    _repository = ref.watch(orderRepositoryProvider);
  }

  /// 새로운 주문을 생성합니다.
  ///
  /// 성공 시 true, 실패 시 false를 반환합니다.
  Future<bool> createOrder({
    required List<CartItemModel> cartItems,
    required int totalAmount,
    required int shippingFee,
    required String recipientName,
    required String recipientPhone,
    required String shippingAddress,
  }) async {
    // UI에 로딩 상태임을 알립니다.
    state = const AsyncValue.loading();
    
    // state = await AsyncValue.guard(...)는 try-catch와 유사하게 동작하여
    // Future 내에서 발생하는 에러를 자동으로 처리하고 state에 담아줍니다.
    state = await AsyncValue.guard(() async {
      await _repository.createOrder(
        cartItems: cartItems,
        totalAmount: totalAmount,
        shippingFee: shippingFee,
        recipientName: recipientName,
        recipientPhone: recipientPhone,
        shippingAddress: shippingAddress,
      );
    });

    // state.hasError가 false이면 주문이 성공한 것입니다.
    if (!state.hasError) {
      // 주문이 성공했으므로, 장바구니 Provider를 무효화(invalidate)하여
      // 장바구니 목록을 새로고침(비워진 상태로) 하도록 신호를 보냅니다.
      ref.invalidate(cartViewModelProvider);
      return true;
    }
    
    // 주문 실패 시
    return false;
  }
}