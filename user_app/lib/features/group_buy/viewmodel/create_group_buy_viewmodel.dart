import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/group_buy_model.dart';
import '../../../data/repositories/group_buy_repository.dart';

// ✅ 1단계: 기존 구조 유지 + 에러 처리 + 로깅
final masterProductsProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  try {
    Logger.debug('마스터 상품 목록 로드 시작', 'MasterProducts');
    
    final repository = ref.watch(groupBuyRepositoryProvider);
    final products = await repository.fetchMasterProducts();
    
    Logger.info('마스터 상품 로드 완료: ${products.length}개', 'MasterProducts');
    return products;
  } catch (error, stackTrace) {
    Logger.error('마스터 상품 로드 실패', error, stackTrace, 'MasterProducts');
    throw ErrorHandler.handleSupabaseError(error);
  }
});

// '공구 설정' 화면의 액션을 위한 ViewModel Provider
final createGroupBuyViewModelProvider =
    StateNotifierProvider.autoDispose<
      CreateGroupBuyViewModel,
      AsyncValue<void>
    >((ref) {
      return CreateGroupBuyViewModel(ref.read(groupBuyRepositoryProvider));
    });

class CreateGroupBuyViewModel extends StateNotifier<AsyncValue<void>> {
  final GroupBuyRepository _repository;
  CreateGroupBuyViewModel(this._repository)
    : super(const AsyncValue.data(null));

  // 💡 반환 타입은 Future<void> 이며, 성공/실패는 state를 통해 외부에 알립니다.
  Future<bool> createGroupBuy({
    required int productId,
    required int targetParticipants,
    required int initialQuantity,
    required DateTime deadline,
  }) async {
    try {
      // 입력 검증
      if (targetParticipants < AppConstants.minGroupBuyParticipants) {
        throw ValidationException('최소 참여자는 ${AppConstants.minGroupBuyParticipants}명입니다.');
      }
      if (targetParticipants > AppConstants.maxGroupBuyParticipants) {
        throw ValidationException('최대 참여자는 ${AppConstants.maxGroupBuyParticipants}명입니다.');
      }
      if (deadline.isBefore(DateTime.now())) {
        throw const ValidationException('마감일은 현재 시간보다 미래여야 합니다.');
      }

      Logger.debug('공동구매 생성 시작: 상품ID $productId', 'CreateGroupBuy');
      
      state = const AsyncValue.loading();
      
      await _repository.createGroupBuyFromMaster(
        productId: productId,
        targetParticipants: targetParticipants,
        initialQuantity: initialQuantity,
        deadline: deadline,
      );
      
      state = const AsyncValue.data(null);
      Logger.info('공동구매 생성 성공', 'CreateGroupBuy');
      return true;
    } catch (error, stackTrace) {
      Logger.error('공동구매 생성 실패', error, stackTrace, 'CreateGroupBuy');
      
      final appError = ErrorHandler.handleSupabaseError(error);
      state = AsyncValue.error(appError, stackTrace);
      return false;
    }
  }
}