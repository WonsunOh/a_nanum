// admin_web/lib/features/shop_management/categories/viewmodel/category_viewmodel.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/repositories/category_repository.dart';

part 'category_viewmodel.g.dart';

// ⭐️ 이 Provider가 화면에서 찾고 있던 'categoriesProvider'입니다.
// keepAlive: true 옵션은 사용자가 다른 화면에 다녀와도 카테고리 목록이 초기화되지 않고
// 유지되도록 하여 불필요한 데이터 로딩을 줄여줍니다.
@Riverpod(keepAlive: true)
class Categories extends _$Categories {
  @override
  Future<List<CategoryModel>> build() async {
    // CategoryRepository를 통해 카테고리 목록 데이터를 가져옵니다.
    return ref.watch(categoryRepositoryProvider).fetchCategories();
  }

  // TODO: 나중에 카테고리를 추가/수정/삭제하는 메서드를 여기에 추가할 수 있습니다.
  // Future<void> addCategory(String name) async { ... }
}