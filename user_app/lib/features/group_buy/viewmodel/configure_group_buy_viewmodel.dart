import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/group_buy_repository.dart';
import '../../../data/models/group_buy_model.dart';

// 1. '상품 선택' 화면을 위한 Provider
final masterProductsProvider = FutureProvider.autoDispose<List<Product>>((ref) {
  return ref.watch(groupBuyRepositoryProvider).fetchMasterProducts();
});

// 2. '공구 설정' 화면의 액션을 위한 ViewModel Provider
final configureGroupBuyViewModelProvider = StateNotifierProvider.autoDispose<ConfigureGroupBuyViewModel, AsyncValue<void>>((ref) {
  return ConfigureGroupBuyViewModel(ref.read(groupBuyRepositoryProvider));
});

class ConfigureGroupBuyViewModel extends StateNotifier<AsyncValue<void>> {
  final GroupBuyRepository _repository;
  ConfigureGroupBuyViewModel(this._repository) : super(const AsyncValue.data(null));

  Future<void> createGroupBuy({
    required int productId,
    required int targetParticipants,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.createGroupBuyFromMaster(
          productId: productId,
          targetParticipants: targetParticipants,
        ));
  }
}