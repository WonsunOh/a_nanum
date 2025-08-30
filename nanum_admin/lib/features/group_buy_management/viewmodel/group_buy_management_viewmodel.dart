import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/managed_group_buy_model.dart';
import '../../../data/repositories/group_buy_admin_repository.dart';

final groupBuyManagementViewModelProvider = StateNotifierProvider.autoDispose<GroupBuyManagementViewModel, 
AsyncValue<List<ManagedGroupBuy>>>((ref) {
   // 👇 이 코드를 추가!
  print("✅ productsProvider가 실행되었습니다!"); 
  return GroupBuyManagementViewModel(ref.read(groupBuyAdminRepositoryProvider));
});

class GroupBuyManagementViewModel extends StateNotifier<AsyncValue<List<ManagedGroupBuy>>> {
  final GroupBuyAdminRepository _repository;
  GroupBuyManagementViewModel(this._repository) : super(const AsyncValue.loading()) {
    fetchAllGroupBuys();
  }

  Future<void> fetchAllGroupBuys() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.fetchAllGroupBuys());
  }

  // 💡 updateStatus 메소드를 delete와 동일한 패턴으로 수정합니다.
  Future<void> updateStatus(int id, String newStatus) async {
    // 1. UI에 로딩 상태를 먼저 알립니다.
    state = const AsyncValue.loading();
    try {
      // 2. 상태 업데이트 작업을 수행합니다.
      await _repository.updateGroupBuyStatus(id, newStatus);
      // 3. 작업이 성공하면, 전체 목록을 새로고침합니다.
      await fetchAllGroupBuys();
    } catch (e, s) {
      // 4. 실패하면 에러 상태로 변경합니다.
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> delete(int id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteGroupBuy(id);
      await fetchAllGroupBuys();
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}