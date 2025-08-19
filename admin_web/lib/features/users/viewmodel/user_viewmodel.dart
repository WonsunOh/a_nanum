import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/app_user_model.dart';
import '../../../data/models/user_detail_model.dart';
import '../../../data/repositories/user_repository.dart';

// 검색어를 관리하는 Provider
final userSearchQueryProvider = StateProvider<String>((ref) => '');

final userViewModelProvider = FutureProvider.autoDispose<List<AppUser>>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  final searchQuery = ref.watch(userSearchQueryProvider);
  
  // 검색어가 변경될 때마다 데이터를 다시 불러옵니다.
  return repository.fetchAllUsers(searchQuery: searchQuery);
});

// 💡 특정 사용자의 상세 정보를 가져오는 Provider (.family 사용)
final userDetailProvider = FutureProvider.autoDispose.family<UserDetail, String>((ref, userId) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.fetchUserDetails(userId);
});