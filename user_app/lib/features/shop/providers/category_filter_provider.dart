// user_app/lib/features/shop/providers/category_filter_provider.dart (새 파일)

import 'package:flutter_riverpod/flutter_riverpod.dart';

// 선택된 카테고리 ID 관리
final selectedCategoryProvider = StateProvider<int?>((ref) => null);

// 검색어 관리
final searchQueryProvider = StateProvider<String>((ref) => '');