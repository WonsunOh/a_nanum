// user_app/lib/features/wishlist/viewmodel/wishlist_viewmodel.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/wishlist_item_model.dart';
import '../../../data/repositories/wishlist_repository.dart';

part 'wishlist_viewmodel.g.dart';

@riverpod
class WishlistViewModel extends _$WishlistViewModel {
  late final WishlistRepository _repository;

  @override
  Future<List<WishlistItemModel>> build() async {
    _repository = ref.watch(wishlistRepositoryProvider);
    return _loadWishlistItems();
  }

  Future<List<WishlistItemModel>> _loadWishlistItems() async {
    try {
      Logger.debug('찜 목록 로드 시작', 'WishlistViewModel');
      
      final items = await _repository.fetchWishlistItems();
      
      Logger.info('찜 목록 로드 완료: ${items.length}개', 'WishlistViewModel');
      return items;
    } catch (error, stackTrace) {
      Logger.error('찜 목록 로드 실패', error, stackTrace, 'WishlistViewModel');
      throw ErrorHandler.handleSupabaseError(error);
    }
  }

  Future<void> addToWishlist(int productId) async {
    try {
      Logger.debug('찜 추가: 상품ID $productId', 'WishlistViewModel');
      
      await _repository.addToWishlist(productId);
      ref.invalidateSelf();
      
      Logger.info('찜 추가 완료', 'WishlistViewModel');
    } catch (error, stackTrace) {
      Logger.error('찜 추가 실패', error, stackTrace, 'WishlistViewModel');
      throw ErrorHandler.handleSupabaseError(error);
    }
  }

  Future<void> removeFromWishlist(int productId) async {
    try {
      Logger.debug('찜 제거: 상품ID $productId', 'WishlistViewModel');
      
      await _repository.removeFromWishlist(productId);
      ref.invalidateSelf();
      
      Logger.info('찜 제거 완료', 'WishlistViewModel');
    } catch (error, stackTrace) {
      Logger.error('찜 제거 실패', error, stackTrace, 'WishlistViewModel');
      throw ErrorHandler.handleSupabaseError(error);
    }
  }
}