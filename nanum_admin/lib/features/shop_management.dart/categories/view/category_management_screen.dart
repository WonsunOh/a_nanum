// admin_web/lib/features/shop_management/categories/view/category_management_screen.dart (전체 교체)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/category_model.dart';
import '../viewmodel/category_viewmodel.dart';
import '../widgets/add_edit_category_dialog.dart'; // ⭐️ 새로 만든 다이얼로그 import
import '../widgets/category_list_item.dart';

class CategoryManagementScreen extends ConsumerWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    // ⭐️ 다이얼로그를 보여주는 함수 완성
    void showAddEditDialog({int? parentId, CategoryModel? categoryToEdit}) {
      showDialog(
        context: context,
        builder: (context) => AddEditCategoryDialog(
          parentId: parentId,
          categoryToEdit: categoryToEdit,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('카테고리 관리 (3-Level)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: '최상위 카테고리 추가',
            onPressed: () => showAddEditDialog(),
          ),
        ],
      ),
      body: categoriesAsync.when(
        data: (rootCategories) {
          if (rootCategories.isEmpty) {
            return const Center(child: Text('등록된 카테고리가 없습니다.'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(categoriesProvider.future),
            child: ListView.builder(
              itemCount: rootCategories.length,
              itemBuilder: (context, index) {
                final category = rootCategories[index];
                // ⭐️ onAdd, onEdit 대신 showAddEditDialog 함수를 직접 전달
                return CategoryListItem(
                  category: category,
                  showAddEditDialog: showAddEditDialog,
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('오류: $e')),
      ),
    );
  }
}