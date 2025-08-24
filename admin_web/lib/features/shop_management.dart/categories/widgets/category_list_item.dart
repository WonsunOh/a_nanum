// admin_web/lib/features/shop_management/categories/widgets/category_list_item.dart (새 파일)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/category_model.dart';
import '../viewmodel/category_viewmodel.dart';

// ⭐️ showAddEditDialog 함수를 직접 받도록 변경
typedef ShowDialogCallback = void Function({int? parentId, CategoryModel? categoryToEdit});


class CategoryListItem extends ConsumerWidget {
  final CategoryModel category;
  final ShowDialogCallback showAddEditDialog;

  const CategoryListItem({
    super.key,
    required this.category,
    required this.showAddEditDialog,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 자식 카테고리가 있으면 ExpansionTile, 없으면 ListTile을 사용
    return category.children.isEmpty
        ? ListTile(
            title: Text(category.name),
            trailing: _buildActionButtons(context, ref),
          )
        : ExpansionTile(
            title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: _buildActionButtons(context, ref),
            children: category.children.map((child) {
              // 재귀적으로 자식 위젯을 생성
              return Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: CategoryListItem(
                  category: child,
                  // ⭐️ showAddEditDialog 함수를 그대로 전달
                  showAddEditDialog: showAddEditDialog,
                ),
              );
            }).toList(),
          );
  }

  // 수정, 삭제, 하위 카테고리 추가 버튼을 만드는 함수
  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    void showDeleteConfirmDialog() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('카테고리 삭제'),
          content: Text('[${category.name}] 카테고리를 삭제하면 하위 카테고리도 모두 삭제됩니다. 정말 삭제하시겠습니까?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('취소')),
            TextButton(
              onPressed: () {
                ref.read(categoriesProvider.notifier).deleteCategory(category.id);
                Navigator.of(context).pop();
              },
              child: const Text('삭제', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.add, color: Colors.blue),
          tooltip: '하위 카테고리 추가',
          onPressed: () => showAddEditDialog(parentId: category.id),
        ),
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: 20),
          tooltip: '이름 수정',
          onPressed: () => showAddEditDialog(categoryToEdit: category),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
          tooltip: '삭제',
          onPressed: showDeleteConfirmDialog,
        ),
      ],
    );
  }
}