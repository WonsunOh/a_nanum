// user_app/lib/features/cart/viewmodel/cart_viewmodel.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/repositories/cart_repository.dart';

part 'cart_viewmodel.g.dart';

class CartState {
  final List<CartItemModel> items;
  final Set<int> selectedItemIds;

  CartState({this.items = const [], this.selectedItemIds = const {}});

  CartState copyWith({List<CartItemModel>? items, Set<int>? selectedItemIds}) {
    return CartState(
      items: items ?? this.items,
      selectedItemIds: selectedItemIds ?? this.selectedItemIds,
    );
  }

  // ✅ variant 가격을 포함한 총 금액 계산
  int get totalAmount {
    return items.fold(0, (sum, item) {
      final basePrice = item.product?.discountPrice ?? item.product?.price ?? 0;
      final variantPrice = item.variantAdditionalPrice ?? 0;
      final finalPrice = basePrice + variantPrice;
      return sum + (finalPrice * item.quantity);
    });
  }

  int get selectedAmount {
    return items.where((item) => selectedItemIds.contains(item.id)).fold(0, (sum, item) {
      final basePrice = item.product?.discountPrice ?? item.product?.price ?? 0;
      final variantPrice = item.variantAdditionalPrice ?? 0;
      final finalPrice = basePrice + variantPrice;
      return sum + (finalPrice * item.quantity);
    });
  }
}

@riverpod
class CartViewModel extends _$CartViewModel {
  // ✅ late final 제거하고 getter로 변경
  CartRepository get _repository => ref.watch(cartRepositoryProvider);

  @override
  Future<CartState> build() async {
    return await _loadCartItems();
  }

  Future<CartState> _loadCartItems() async {
    try {
      final items = await _repository.fetchCartItems();
      return CartState(items: items);
    } catch (error) {
      print('장바구니 로드 에러: $error');
      return CartState();
    }
  }

  Future<void> addProductToCart({
  required int productId,
  required int quantity,
  int? variantId,
}) async {
  try {
    
    await _repository.addProductToCart(
      productId: productId,
      quantity: quantity,
      variantId: variantId, // ✅ 그대로 전달
    );
    
    ref.invalidateSelf();
  } catch (error) {
    print('장바구니 추가 에러: $error');
    throw error;
  }
}

  Future<void> updateQuantity(int cartItemId, int newQuantity) async {
    try {
      if (newQuantity <= 0) {
        await removeProduct(cartItemId);
        return;
      }
      
      await _repository.updateCartItemQuantity(
        cartItemId: cartItemId,
        newQuantity: newQuantity,
      );
      ref.invalidateSelf();
    } catch (error) {
      print('수량 변경 에러: $error');
      throw error;
    }
  }

  Future<void> removeProduct(int cartItemId) async {
    try {
      await _repository.removeCartItem(cartItemId);
      ref.invalidateSelf();
    } catch (error) {
      print('상품 제거 에러: $error');
      throw error;
    }
  }

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

  void toggleSelectAll() {
    final currentState = state.valueOrNull ?? CartState();
    if (currentState.items.isEmpty) return;

    final allIds = currentState.items.map((e) => e.id).toSet();
    if (currentState.selectedItemIds.length == allIds.length) {
      state = AsyncData(currentState.copyWith(selectedItemIds: {}));
    } else {
      state = AsyncData(currentState.copyWith(selectedItemIds: allIds));
    }
  }
}