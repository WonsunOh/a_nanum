import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/managed_group_buy_model.dart';
import '../../../data/repositories/group_buy_admin_repository.dart';

/// ## GroupBuy Management ViewModel Provider
/// '공구 관리' 화면에 필요한 데이터 목록을 제공하는 FutureProvider입니다.
final groupBuyManagementViewModelProvider = FutureProvider.autoDispose<List<ManagedGroupBuy>>((ref) {
  // GroupBuyAdminRepository를 watch하여 데이터를 가져옵니다.
  // 검색이나 필터 기능이 추가되면, 관련 Provider를 watch하여 repository에 전달할 수 있습니다.
  return ref.watch(groupBuyAdminRepositoryProvider).fetchAllGroupBuys();
});