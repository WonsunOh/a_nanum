// user_app/lib/features/cart/viewmodel/cart_viewmodel.dart (전체 교체)
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/repositories/cart_repository.dart';

part 'cart_viewmodel.g.dart';

// ⭐️ 1. 장바구니의 전체 상태를 담을 클래스
class CartState {
  final List<CartItemModel> items;
  final Set<int> selectedItemIds; // 선택된 아이템들의 ID를 저장

  CartState({this.items = const [], this.selectedItemIds = const {}});

  CartState copyWith({
    List<CartItemModel>? items,
    Set<int>? selectedItemIds,
  }) {
    return CartState(
      items: items ?? this.items,
      selectedItemIds: selectedItemIds ?? this.selectedItemIds,
    );
  }
}


// ⭐️ 2. Provider를 NotifierProvider로 변경
@riverpod
class CartViewModel extends _$CartViewModel {
  late final CartRepository _repository;

  @override
  Future<CartState> build() async {
    _repository = ref.watch(cartRepositoryProvider);
    final items = await _repository.fetchCartItems();
    // ⭐️ 초기 상태: 모든 아이템이 선택된 상태로 시작
    return CartState(items: items, selectedItemIds: items.map((e) => e.id).toSet());
  }

  // ⭐️ 3. 아이템 선택/해제 메서드
  void toggleItemSelection(int cartItemId) {
    final currentState = state.valueOrNull ?? CartState();
    final currentSelection = currentState.selectedItemIds.toSet();

    if (currentSelection.contains(cartItemId)) {
      currentSelection.remove(cartItemId);
    } else {
      currentSelection.add(cartItemId);
    }
    
    state = AsyncData(currentState.copyWith(selectedItemIds: currentSelection));
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
  Future<void> addProductToCart({required int productId, required int quantity}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.addProductToCart(productId: productId, quantity: quantity);
      final items = await _repository.fetchCartItems();
      return CartState(items: items, selectedItemIds: items.map((e) => e.id).toSet());
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