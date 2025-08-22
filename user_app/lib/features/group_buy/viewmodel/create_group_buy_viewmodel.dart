import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/group_buy_model.dart';
import '../../../data/repositories/group_buy_repository.dart';

// '상품 선택' 화면을 위한 Provider
final masterProductsProvider = FutureProvider.autoDispose<List<Product>>((ref) {
  final repository = ref.watch(groupBuyRepositoryProvider);
  return repository.fetchMasterProducts();
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
    state = const AsyncValue.loading();
    try {
      // Repository의 함수를 직접 호출합니다.
      await _repository.createGroupBuyFromMaster(
        productId: productId,
        targetParticipants: targetParticipants,
        initialQuantity: initialQuantity,
        deadline: deadline,
      );
      // 성공 시, state를 data로 변경하고 true를 반환합니다.
      state = const AsyncValue.data(null);
      return true;
    } catch (e, s) {
      // --- 👇 여기가 핵심 수정 부분 ---
      // 에러가 발생하면, 콘솔에 전체 내용을 출력합니다.
      print('--- 공구 개설 에러 발생 ---');
      print('에러 종류: $e');
      print('에러 위치 (Stack Trace): $s');
      // --- 👆 여기까지 ---

      // state를 error로 변경하고 false를 반환합니다.
      state = AsyncValue.error(e, s);
      return false;
    }
  }
}
