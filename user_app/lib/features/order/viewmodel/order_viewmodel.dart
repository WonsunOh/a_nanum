// user_app/lib/features/order/viewmodel/order_viewmodel.dart (전체 코드)

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/repositories/order_repository.dart';
import '../../cart/viewmodel/cart_viewmodel.dart';

part 'order_viewmodel.g.dart';

@riverpod
class OrderViewModel extends _$OrderViewModel {
  OrderRepository get _repository => ref.watch(orderRepositoryProvider);

  @override
  Future<void> build() async {
  }

  /// 새로운 주문을 생성합니다.
  ///
  /// 성공 시 true, 실패 시 false를 반환합니다.
  // user_app/lib/features/order/viewmodel/order_viewmodel.dart의 createOrder 메서드 수정
  // user_app/lib/features/order/viewmodel/order_viewmodel.dart 수정
Future<bool> createOrder({
  required List<CartItemModel> cartItems,
  required int totalAmount,
  required int shippingFee,
  required String recipientName,
  required String recipientPhone,
  required String shippingAddress,
  String? paymentId,
}) async {
  
  // UI에 로딩 상태임을 알립니다.
  state = const AsyncValue.loading();
  
  try {
    // ⭐️ 직접 try-catch로 감싸서 에러를 확인
    final result = await _repository.createOrder(
      cartItems: cartItems,
      totalAmount: totalAmount,
      shippingFee: shippingFee,
      recipientName: recipientName,
      recipientPhone: recipientPhone,
      shippingAddress: shippingAddress,
      paymentId: paymentId,
    );
    
    
    if (result != null) {
      state = const AsyncValue.data(null);
      ref.invalidate(cartViewModelProvider);
      return true;
    } else {
      state = AsyncValue.error('주문 생성 실패', StackTrace.current);
      return false;
    }
  } catch (e, stackTrace) {
    print('❌ OrderViewModel 에러: $e');
    print('📍 스택 트레이스: $stackTrace');
    state = AsyncValue.error(e, stackTrace);
    return false;
  }
}
}
