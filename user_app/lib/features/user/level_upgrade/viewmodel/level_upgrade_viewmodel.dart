// user_app/lib/features/user/level_upgrade/viewmodel/level_upgrade_viewmodel.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/level_upgrade_repository.dart';
import '../../../../data/models/level_upgrade_request_model.dart';

class LevelUpgradeViewModel extends StateNotifier<AsyncValue<List<LevelUpgradeRequest>>> {
  final LevelUpgradeRepository _repository;

  LevelUpgradeViewModel(this._repository) : super(const AsyncValue.loading()) {
    loadUpgradeRequests();
  }

  /// 레벨 업그레이드 신청 기록 로드
  Future<void> loadUpgradeRequests() async {
    state = const AsyncValue.loading();
    try {
      final requests = await _repository.getUserUpgradeRequests();
      state = AsyncValue.data(requests);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  /// 레벨 업그레이드 신청 제출
  Future<bool> submitUpgradeRequest({
    required int currentLevel,
    required int requestedLevel,
    required String reason,
    String? additionalInfo,
  }) async {
    try {
      // 먼저 진행 중인 신청이 있는지 확인
      final hasPending = await _repository.hasPendingRequest();
      if (hasPending) {
        throw Exception('이미 진행 중인 레벨 업그레이드 신청이 있습니다.');
      }

      await _repository.submitUpgradeRequest(
        currentLevel: currentLevel,
        requestedLevel: requestedLevel,
        reason: reason,
        additionalInfo: additionalInfo,
      );

      // 신청 후 목록 새로고침
      await loadUpgradeRequests();
      return true;
    } catch (e) {
      rethrow;
    }
  }
}

final levelUpgradeViewModelProvider =
    StateNotifierProvider<LevelUpgradeViewModel, AsyncValue<List<LevelUpgradeRequest>>>(
  (ref) => LevelUpgradeViewModel(ref.read(levelUpgradeRepositoryProvider)),
);

// 진행 중인 신청 확인용 Provider
final hasPendingUpgradeRequestProvider = FutureProvider<bool>((ref) async {
  final repository = ref.read(levelUpgradeRepositoryProvider);
  return await repository.hasPendingRequest();
});