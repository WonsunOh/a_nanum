import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/utils/logger.dart';
import '../../../../data/models/group_buy_model.dart';
import '../../../../data/models/my_participation_model.dart';
import '../../../../data/repositories/group_buy_repository.dart';

// 💡 '내가 참여한 공구' 목록과 액션을 모두 관리하는 단일 ViewModel Provider
final myPageViewModelProvider = StateNotifierProvider.autoDispose<MyPageViewModel, AsyncValue<List<MyParticipation>>>((ref) {
  return MyPageViewModel(ref.read(groupBuyRepositoryProvider));
});

final myHostedGroupBuysProvider = FutureProvider.autoDispose<List<GroupBuy>>((ref) async {
  try {
    Logger.debug('내가 개설한 공구 로드 시작', 'MyHostedGroupBuys');
    
    final repository = ref.watch(groupBuyRepositoryProvider);
    final groupBuys = await repository.fetchMyHostedGroupBuys();
    
    Logger.info('개설한 공구 로드 완료: ${groupBuys.length}개', 'MyHostedGroupBuys');
    return groupBuys;
  } catch (error, stackTrace) {
    Logger.error('개설한 공구 로드 실패', error, stackTrace, 'MyHostedGroupBuys');
    throw ErrorHandler.handleSupabaseError(error);
  }
});


class MyPageViewModel extends StateNotifier<AsyncValue<List<MyParticipation>>> {
  final GroupBuyRepository _repository;

  MyPageViewModel(this._repository) : super(const AsyncValue.loading()) {
    fetchMyParticipations();
  }

  // ✅ 1단계: 기존 기능 + 에러 처리 + 로깅
  Future<void> fetchMyParticipations() async {
    try {
      Logger.debug('내 참여 목록 로드 시작', 'MyPageViewModel');
      
      state = const AsyncValue.loading();
      final participations = await _repository.fetchMyParticipations();
      
      state = AsyncValue.data(participations);
      Logger.info('참여 목록 로드 완료: ${participations.length}개', 'MyPageViewModel');
    } catch (error, stackTrace) {
      Logger.error('참여 목록 로드 실패', error, stackTrace, 'MyPageViewModel');
      state = AsyncValue.error(ErrorHandler.handleSupabaseError(error), stackTrace);
    }
  }

  Future<void> cancelParticipation(int groupBuyId) async {
    try {
      Logger.debug('참여 취소 시도: 공구ID $groupBuyId', 'MyPageViewModel');
      
      state = const AsyncValue.loading();
      await _repository.cancelParticipation(groupBuyId);
      
      await fetchMyParticipations(); // 목록 새로고침
      Logger.info('참여 취소 완료', 'MyPageViewModel');
    } catch (error, stackTrace) {
      Logger.error('참여 취소 실패', error, stackTrace, 'MyPageViewModel');
      state = AsyncValue.error(ErrorHandler.handleSupabaseError(error), stackTrace);
    }
  }

  Future<void> editQuantity(int groupBuyId, int newQuantity) async {
    try {
      // 수량 검증
      if (newQuantity < 1) {
        throw const ValidationException('수량은 1개 이상이어야 합니다.');
      }

      Logger.debug('수량 변경 시도: 공구ID $groupBuyId, 새 수량 $newQuantity', 'MyPageViewModel');
      
      state = const AsyncValue.loading();
      await _repository.editQuantity(groupBuyId, newQuantity);
      
      await fetchMyParticipations(); // 목록 새로고침
      Logger.info('수량 변경 완료', 'MyPageViewModel');
    } catch (error, stackTrace) {
      Logger.error('수량 변경 실패', error, stackTrace, 'MyPageViewModel');
      state = AsyncValue.error(ErrorHandler.handleSupabaseError(error), stackTrace);
    }
  }
}