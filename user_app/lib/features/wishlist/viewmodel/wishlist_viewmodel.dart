// user_app/lib/features/wishlist/viewmodel/wishlist_viewmodel.dart (전체 교체)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/wishlist_item_model.dart';
import '../../../data/repositories/wishlist_repository.dart';

// 찜 목록 상태 관리 Provider
final wishlistViewModelProvider = StateNotifierProvider<WishlistViewModel, AsyncValue<List<WishlistItemModel>>>((ref) {
  return WishlistViewModel(ref);
});

class WishlistViewModel extends StateNotifier<AsyncValue<List<WishlistItemModel>>> {
  final Ref _ref;
  late final WishlistRepository _repository;

  WishlistViewModel(this._ref) : super(const AsyncLoading()) {
    _repository = _ref.watch(wishlistRepositoryProvider);
    _loadWishlistItems();
  }

  Future<void> _loadWishlistItems() async {
    try {
      print('찜 목록 로드 시작...');
      
      state = const AsyncLoading();
      final items = await _repository.fetchWishlistItems();
      
      print('찜 목록 로드 완료: ${items.length}개');
      state = AsyncData(items);
    } catch (error, stackTrace) {
      print('찜 목록 로드 실패: $error');
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> addToWishlist(int productId) async {
    try {
      print('찜 추가: 상품ID $productId');
      
      await _repository.addToWishlist(productId);
      await _loadWishlistItems(); // 목록 새로고침
      
      print('찜 추가 완료');
    } catch (error, stackTrace) {
      print('찜 추가 실패: $error');
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> removeFromWishlist(int productId) async {
    try {
      print('찜 제거: 상품ID $productId');
      
      await _repository.removeFromWishlist(productId);
      await _loadWishlistItems(); // 목록 새로고침
      
      print('찜 제거 완료');
    } catch (error, stackTrace) {
      print('찜 제거 실패: $error');
      state = AsyncError(error, stackTrace);
    }
  }

  // 수동 새로고침
  void refresh() {
    _loadWishlistItems();
  }
}

// 개별 상품 찜 상태 확인 Provider
final isProductWishlistedProvider = FutureProvider.family<bool, int>((ref, productId) async {
  final repository = ref.watch(wishlistRepositoryProvider);
  return repository.isProductWishlisted(productId);
});

// 찜하기 토글 Provider
final wishlistToggleProvider = StateNotifierProvider<WishlistToggleNotifier, AsyncValue<void>>((ref) {
  return WishlistToggleNotifier(ref);
});

class WishlistToggleNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  WishlistToggleNotifier(this._ref) : super(const AsyncData(null));


Future<String> toggleWishlist(int productId) async {
    try {
      final repository = _ref.read(wishlistRepositoryProvider);
      
      // 현재 찜 상태 확인
      final isCurrentlyWishlisted = await repository.isProductWishlisted(productId);
      print('현재 찜 상태: $isCurrentlyWishlisted (상품 $productId)');
      
      String actionMessage;
      
      if (isCurrentlyWishlisted) {
        // 찜 해제
        await repository.removeFromWishlist(productId);
        actionMessage = '찜 목록에서 제거되었습니다';
        print('찜 제거 완료: $productId');
      } else {
        // 찜 추가
        await repository.addToWishlist(productId);
        actionMessage = '찜 목록에 추가되었습니다';
        print('찜 추가 완료: $productId');
      }
      
      // Provider 무효화하여 UI 업데이트
      _ref.invalidate(isProductWishlistedProvider(productId));
      _ref.invalidate(wishlistViewModelProvider);
      
      state = const AsyncData(null);
      return actionMessage;
      
    } catch (error, stackTrace) {
      print('찜 토글 실패: $error');
      state = AsyncError(error, stackTrace);
      throw error;
    }
  }
}