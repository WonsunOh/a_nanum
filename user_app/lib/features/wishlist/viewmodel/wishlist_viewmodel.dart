// user_app/lib/features/wishlist/viewmodel/wishlist_viewmodel.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/models/wishlist_item_model.dart';
import '../../../data/repositories/wishlist_repository.dart';

part 'wishlist_viewmodel.g.dart';

@riverpod
class WishlistViewModel extends _$WishlistViewModel {
  late final WishlistRepository _repository;

  @override
  Future<List<WishlistItemModel>> build() {
    _repository = ref.watch(wishlistRepositoryProvider);
    return _repository.fetchWishlistItems();
  }

  Future<void> add(int productId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.addToWishlist(productId);
      return _repository.fetchWishlistItems();
    });
  }

  Future<void> remove(int productId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.removeFromWishlist(productId);
      return _repository.fetchWishlistItems();
    });
  }
}