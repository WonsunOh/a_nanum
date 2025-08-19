import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/group_buy_model.dart';
import '../../../data/models/my_participation_model.dart';
import '../../../data/repositories/group_buy_repository.dart';

// 💡 ViewModel Provider를 하나로 통합합니다.
final myPageViewModelProvider = StateNotifierProvider.autoDispose<MyPageViewModel, AsyncValue<List<MyParticipation>>>((ref) {
  return MyPageViewModel(ref.read(groupBuyRepositoryProvider));
});

class MyPageViewModel extends StateNotifier<AsyncValue<List<MyParticipation>>> {
  final GroupBuyRepository _repository;

  MyPageViewModel(this._repository) : super(const AsyncValue.loading()) {
    // 💡 ViewModel이 생성되자마자 최초 데이터를 로드합니다.
    fetchMyParticipations();
  }

  /// 데이터 로드 및 새로고침
  Future<void> fetchMyParticipations() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.fetchMyParticipations());
  }

  /// 참여 취소
  Future<void> cancelParticipation(int groupBuyId) async {
    // 로딩 상태를 UI에 알립니다.
    state = const AsyncValue.loading();
    // guard는 작업 중 발생할 수 있는 에러를 자동으로 AsyncError 상태로 처리해줍니다.
    await AsyncValue.guard(() => _repository.cancelParticipation(groupBuyId));
    // 💡 작업 완료 후, 목록을 다시 불러와 state를 갱신합니다.
    await fetchMyParticipations();
  }

  /// 수량 변경
  Future<void> editQuantity(int groupBuyId, int newQuantity) async {
    state = const AsyncValue.loading();
    await AsyncValue.guard(() => _repository.editQuantity(groupBuyId, newQuantity));
    // 💡 작업 완료 후, 목록을 다시 불러와 state를 갱신합니다.
    await fetchMyParticipations();
  }
}

// 💡 내가 개설한 공구 목록을 가져오는 Provider
final myHostedGroupBuysProvider = FutureProvider.autoDispose<List<GroupBuy>>((ref) {
  final repository = ref.watch(groupBuyRepositoryProvider);
  return repository.fetchMyHostedGroupBuys();
});