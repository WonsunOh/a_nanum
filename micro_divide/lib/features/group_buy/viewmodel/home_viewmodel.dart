import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/group_buy_model.dart';
import '../../../data/repositories/group_buy_repository.dart';

// 💡 새로운 StateNotifierProvider를 생성합니다.
final homeViewModelProvider = StateNotifierProvider.autoDispose<HomeViewModel, AsyncValue<List<GroupBuy>>>((ref) {
  return HomeViewModel(ref);
});

class HomeViewModel extends StateNotifier<AsyncValue<List<GroupBuy>>> {
  final Ref _ref;
  StreamSubscription? _subscription;

  HomeViewModel(this._ref) : super(const AsyncLoading()) {
    _listenToGroupBuys();
  }

  void _listenToGroupBuys() {
    final repository = _ref.read(groupBuyRepositoryProvider);
    _subscription = repository.watchGroupBuys().listen((groupBuys) async {
      // 새로운 공동구매 목록을 받으면, 각 항목의 상품 정보를 가져옵니다.
      final populatedGroupBuys = await _fetchProductsForGroupBuys(groupBuys);
      state = AsyncValue.data(populatedGroupBuys);
    }, onError: (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    });
  }

  Future<List<GroupBuy>> _fetchProductsForGroupBuys(List<GroupBuy> groupBuys) async {
    final repository = _ref.read(groupBuyRepositoryProvider);
    final futures = groupBuys.map((gb) async {
      if (gb.product == null) {
        final product = await repository.fetchProductById(gb.productId);
        return gb.copyWith(product: product); // copyWith로 product 정보 업데이트
      }
      return gb;
    }).toList();
    return await Future.wait(futures);
  }

  // Provider가 소멸될 때 구독을 정리합니다.
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}