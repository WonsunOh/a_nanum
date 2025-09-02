// user_app/lib/features/cart/viewmodel/cart_viewmodel.dart (전체 교체)
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/repositories/cart_repository.dart';

part 'cart_viewmodel.g.dart';

// ⭐️ 1. 장바구니의 전체 상태를 담을 클래스
class CartState {
  final List<CartItemModel> items;
  final Set<int> selectedItemIds; // 선택된 아이템들의 ID를 저장

  CartState({this.items = const [], this.selectedItemIds = const {}});

  CartState copyWith({List<CartItemModel>? items, Set<int>? selectedItemIds}) {
    return CartState(
      items: items ?? this.items,
      selectedItemIds: selectedItemIds ?? this.selectedItemIds,
    );
  }
}

// // ✅ 계산 메서드들
//   int get totalAmount {
//     return items.fold(0, (sum, item) {
//       final price = item.product?.discountPrice ?? item.product?.price ?? 0;
//       return sum + (price * item.quantity);
//     });
//   }

//   int get selectedAmount {
//     return items.where((item) => selectedItemIds.contains(item.id)).fold(0, (sum, item) {
//       final price = item.product?.discountPrice ?? item.product?.price ?? 0;
//       return sum + (price * item.quantity);
//     });
//   }

//   int get totalItemCount {
//     return items.fold(0, (sum, item) => sum + item.quantity);
//   }

@riverpod
class CartViewModel extends _$CartViewModel {
  late final CartRepository _repository;

  @override
  Future<CartState> build() async {
    _repository = ref.watch(cartRepositoryProvider);
    return await _loadCartItems();
  }

  Future<CartState> _loadCartItems() async {
    try {
      Logger.debug('장바구니 아이템 로드 시작', 'CartViewModel');

      final items = await _repository.fetchCartItems();

      Logger.info('장바구니 로드 완료: ${items.length}개', 'CartViewModel');
      return CartState(items: items);
    } catch (error, stackTrace) {
      Logger.error('장바구니 로드 실패', error, stackTrace, 'CartViewModel');
      throw ErrorHandler.handleSupabaseError(error);
    }
  }

  // ✅ 1단계: 기존 기능 + 에러 처리 + 검증
  Future<void> addItem(int productId, int quantity) async {
    try {
      // 입력 검증
      if (quantity < AppConstants.minCartItemQuantity) {
        throw const ValidationException(
          '최소 수량은 ${AppConstants.minCartItemQuantity}개입니다.',
        );
      }
      if (quantity > AppConstants.maxCartItemQuantity) {
        throw const ValidationException(
          '최대 수량은 ${AppConstants.maxCartItemQuantity}개입니다.',
        );
      }

      Logger.debug('장바구니 추가: 상품ID $productId, 수량 $quantity', 'CartViewModel');

      await _repository.addProductToCart(
        productId: productId,
        quantity: quantity,
      );

      // 상태 새로고침
      ref.invalidateSelf();
      Logger.info('장바구니 추가 완료', 'CartViewModel');
    } catch (error, stackTrace) {
      Logger.error('장바구니 추가 실패', error, stackTrace, 'CartViewModel');
      throw ErrorHandler.handleSupabaseError(error);
    }
  }

  Future<void> updateQuantity(int cartItemId, int newQuantity) async {
    try {
      // 입력 검증
      if (newQuantity < AppConstants.minCartItemQuantity) {
        throw const ValidationException(
          '최소 수량은 ${AppConstants.minCartItemQuantity}개입니다.',
        );
      }
      if (newQuantity > AppConstants.maxCartItemQuantity) {
        throw const ValidationException(
          '최대 수량은 ${AppConstants.maxCartItemQuantity}개입니다.',
        );
      }

      Logger.debug(
        '수량 변경: 아이템ID $cartItemId, 새 수량 $newQuantity',
        'CartViewModel',
      );

      await _repository.updateCartItemQuantity(
        cartItemId: cartItemId,
        newQuantity: newQuantity,
      );
      ref.invalidateSelf();

      Logger.info('수량 변경 완료', 'CartViewModel');
    } catch (error, stackTrace) {
      Logger.error('수량 변경 실패', error, stackTrace, 'CartViewModel');
      throw ErrorHandler.handleSupabaseError(error);
    }
  }

  // Future<void> removeItem(int cartItemId) async {
  //   try {
  //     Logger.debug('장바구니 제거: 아이템ID $cartItemId', 'CartViewModel');

  //     await _repository.removeFromCart(cartItemId);
  //     ref.invalidateSelf();

  //     Logger.info('장바구니 제거 완료', 'CartViewModel');
  //   } catch (error, stackTrace) {
  //     Logger.error('장바구니 제거 실패', error, stackTrace, 'CartViewModel');
  //     throw ErrorHandler.handleSupabaseError(error);
  //   }
  // }

  // ⭐️ 3. 아이템 선택/해제 메서드
  void toggleItemSelection(int cartItemId) {
    state.whenData((currentState) {
      final selectedIds = Set<int>.from(currentState.selectedItemIds);

      if (selectedIds.contains(cartItemId)) {
        selectedIds.remove(cartItemId);
      } else {
        selectedIds.add(cartItemId);
      }

      state = AsyncValue.data(
        currentState.copyWith(selectedItemIds: selectedIds),
      );
    });
  }

  // ⭐️ 4. 전체 선택/해제 메서드
  void toggleSelectAll() {
    final currentState = state.valueOrNull ?? CartState();
    if (currentState.items.isEmpty) return;

    final allIds = currentState.items.map((e) => e.id).toSet();
    // 모두 선택되어 있으면 전체 해제, 그렇지 않으면 전체 선택
    if (currentState.selectedItemIds.length == allIds.length) {
      state = AsyncData(currentState.copyWith(selectedItemIds: {}));
    } else {
      state = AsyncData(currentState.copyWith(selectedItemIds: allIds));
    }
  }

  // ⭐️ 5. 기존 메서드들이 새로운 상태(CartState)를 반환하도록 수정
  Future<void> addProductToCart({
    required int productId,
    required int quantity,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.addProductToCart(
        productId: productId,
        quantity: quantity,
      );
      final items = await _repository.fetchCartItems();
      return CartState(
        items: items,
        selectedItemIds: items.map((e) => e.id).toSet(),
      );
    });
  }

  // ... (updateQuantity, removeProduct도 동일하게 수정)
  Future<void> removeProduct(int cartItemId) async {
    // ...
    state = await AsyncValue.guard(() async {
      await _repository.removeCartItem(cartItemId);
      final items = await _repository.fetchCartItems();
      final currentSelection = state.value?.selectedItemIds ?? {};
      currentSelection.remove(cartItemId);
      return CartState(items: items, selectedItemIds: currentSelection);
    });
  }
}
