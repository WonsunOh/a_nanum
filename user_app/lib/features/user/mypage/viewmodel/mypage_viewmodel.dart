import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/group_buy_model.dart';
import '../../../../data/models/my_participation_model.dart';
import '../../../../data/repositories/group_buy_repository.dart';

// 💡 '내가 참여한 공구' 목록과 액션을 모두 관리하는 단일 ViewModel Provider
final myPageViewModelProvider = StateNotifierProvider.autoDispose<MyPageViewModel, AsyncValue<List<MyParticipation>>>((ref) {
  return MyPageViewModel(ref.read(groupBuyRepositoryProvider));
});

// 💡 '내가 개설한 공구' 목록을 위한 Provider (이것은 그대로 유지)
final myHostedGroupBuysProvider = FutureProvider.autoDispose<List<GroupBuy>>((ref) {
  final repository = ref.watch(groupBuyRepositoryProvider);
  return repository.fetchMyHostedGroupBuys();
});


class MyPageViewModel extends StateNotifier<AsyncValue<List<MyParticipation>>> {
  final GroupBuyRepository _repository;

  MyPageViewModel(this._repository) : super(const AsyncValue.loading()) {
    fetchMyParticipations();
  }

  // 데이터 로드 및 새로고침
  Future<void> fetchMyParticipations() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.fetchMyParticipations());
  }

  // 참여 취소 (반환 타입 void)
  Future<void> cancelParticipation(int groupBuyId) async {
    // 낙관적 업데이트: UI를 먼저 로딩 상태로 변경
    state = const AsyncValue.loading();
    // guard를 사용해 repository 호출
    await AsyncValue.guard(() => _repository.cancelParticipation(groupBuyId));
    // 작업 완료 후, 목록을 다시 불러와 state를 갱신
    await fetchMyParticipations();
  }

  // 수량 변경 (반환 타입 void)
  Future<void> editQuantity(int groupBuyId, int newQuantity) async {
    state = const AsyncValue.loading();
    await AsyncValue.guard(() => _repository.editQuantity(groupBuyId, newQuantity));
    await fetchMyParticipations();
  }
}