import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/models/app_user_model.dart';
import '../../../data/models/user_detail_model.dart';
import '../../../data/repositories/user_repository.dart';

part 'user_viewmodel.g.dart';

// ⭐️ 1. StateNotifierProvider 대신 AsyncNotifierProvider를 사용하도록 변경합니다.
@riverpod
class UserViewModel extends _$UserViewModel {
 UserRepository get _repository => ref.read(userRepositoryProvider);


  // ⭐️ 2. build 메서드는 Provider가 처음 호출될 때 한 번만 실행됩니다.
  // 여기서 비동기 데이터 로딩을 하고 그 결과를 반환하면 됩니다.
  // 더 이상 생성자에서 데이터를 불러올 필요가 없습니다.
  @override
  Future<List<AppUser>> build() async {
    
    final searchQuery = ref.watch(userSearchQueryProvider);
    // getter를 사용하여 안전하게 repository를 호출합니다.
    return _repository.fetchAllUsers(searchQuery: searchQuery);
  }

  // 레벨을 업데이트하는 함수
  Future<void> updateUserLevel(String userId, int newLevel) async {
    // UI를 즉시 로딩 상태로 변경하여 사용자에게 피드백을 줍니다.
    state = const AsyncValue.loading();
    
    // AsyncValue.guard를 사용하면 try/catch 없이도 에러를 안전하게 처리할 수 있습니다.
    state = await AsyncValue.guard(() async {
      await _repository.updateUserLevel(userId, newLevel);
      
      // ⭐️ 데이터 수정이 성공하면, Provider를 무효화하여 목록을 자동으로 새로고침합니다.
      ref.invalidateSelf();

      // build()가 다시 실행되어 최신 목록을 가져올 것이므로,
      // 여기서는 특별한 값을 반환할 필요가 없습니다. 
      // 이전 데이터를 잠시 보여주려면 return future; 등을 사용할 수 있습니다.
      // 하지만 우리는 목록 전체를 다시 로드할 것이므로 그냥 둡니다.
      return build();
    });
  }
}

// ⭐️ 검색어를 위한 간단한 StateProvider는 그대로 사용합니다.
@riverpod
class UserSearchQuery extends _$UserSearchQuery {
  @override
  String build() => '';

  void setSearchQuery(String query) {
    state = query;
  }
}
@riverpod
class UserDetail extends _$UserDetail {
  // 💥 여기도 동일하게 getter 방식으로 수정합니다.
  UserRepository get _repository => ref.read(userRepositoryProvider);


  // build 메서드에 userId를 인자로 받습니다.
@override
  Future<UserDetailModel> build(String userId) async {
    return _repository.fetchUserDetails(userId);
  }


}