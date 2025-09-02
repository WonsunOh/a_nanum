import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/error_handler.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/group_buy_model.dart';
import '../../../data/repositories/group_buy_repository.dart';

final quantityProvider = StateProvider.autoDispose<int>((ref) => 1);

final groupBuyDetailViewModelProvider = StateNotifierProvider.autoDispose<GroupBuyDetailViewModel, AsyncValue<void>>((ref) {
  return GroupBuyDetailViewModel(ref.read(groupBuyRepositoryProvider));
});

// 💡 id를 파라미터로 받아, 해당하는 단일 GroupBuy 정보를 가져오는 Provider
final groupBuyDetailProvider = FutureProvider.autoDispose.family<GroupBuy?, int>((ref, groupBuyId) {
  // TODO: Repository에 ID로 단일 공구를 가져오는 메소드(getGroupBuyById)를 만들어야 합니다.
  return ref.watch(groupBuyRepositoryProvider).getGroupBuyById(groupBuyId);
});

class GroupBuyDetailViewModel extends StateNotifier<AsyncValue<void>> {
  final GroupBuyRepository _repository;
  
  GroupBuyDetailViewModel(this._repository) : super(const AsyncValue.data(null));

  Future<void> createGroupBuy({
    required String name,
    required int totalPrice,
    required int targetParticipants,
    required XFile image,
    String? description,
    int? categoryId,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final imageBytes = await image.readAsBytes();
      final imageUrl = await _repository.uploadProductImage(imageBytes: imageBytes, imageName: image.name);
      
      await _repository.createNewGroupBuy(
        name: name,
        totalPrice: totalPrice,
        targetParticipants: targetParticipants,
        imageUrl: imageUrl,
        description: description,
        categoryId: categoryId,
      );
    });
  }

  Future<void> joinGroupBuy({
    required int groupBuyId, 
    required int quantity
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.joinGroupBuy(
      groupBuyId: groupBuyId,
      quantity: quantity,
    ));
  }

  // 💡 공구 취소 메소드 추가
  Future<void> cancelGroupBuy(int groupBuyId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.cancelGroupBuy(groupBuyId));
  }

  // 💡 목표 수량 수정 메소드
  Future<void> updateTargetQuantity({required int groupBuyId, required int newQuantity}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.updateTargetQuantity(
      groupBuyId: groupBuyId,
      newQuantity: newQuantity,
    ));
  }
}

// 💡 현재 사용자가 특정 공구에 참여했는지 여부를 확인하는 Provider
// .family를 사용하면 Provider에 파라미터(groupBuyId)를 전달할 수 있습니다.
final hasJoinedProvider = FutureProvider.autoDispose.family<bool, int>((ref, groupBuyId) async {
  try {
    Logger.debug('참여 상태 확인 시작: 공구ID $groupBuyId', 'HasJoined');
    
    final repository = ref.watch(groupBuyRepositoryProvider);
    final currentUser = Supabase.instance.client.auth.currentUser;

    if (currentUser == null) {
      Logger.debug('비로그인 사용자 - 참여 상태: false', 'HasJoined');
      return false;
    }

    final participantUids = await repository.getParticipantUids(groupBuyId);
    final hasJoined = participantUids.contains(currentUser.id);
    
    Logger.info('참여 상태 확인 완료: $hasJoined', 'HasJoined');
    return hasJoined;
  } catch (error, stackTrace) {
    Logger.error('참여 상태 확인 실패', error, stackTrace, 'HasJoined');
    throw ErrorHandler.handleSupabaseError(error);
  }
});