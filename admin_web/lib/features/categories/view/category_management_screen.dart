import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/main_layout.dart';
import '../../../data/models/category_model.dart';
import '../../products/viewmodel/product_viewmodel.dart';
import '../viewmodel/category_viewmodel.dart';

class CategoryManagementScreen extends ConsumerWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedL1 = ref.watch(selectedL1CategoryProvider);
    final selectedL2 = ref.watch(selectedL2CategoryProvider);

    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '카테고리 관리',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('새 카테고리 추가'),
                  onPressed: () {
                    // 💡 '새 카테고리 추가' 버튼을 누를 때, 현재 선택된 카테고리 정보를 전달합니다.
                    _showCategoryDialog(context, ref, selectedL1: selectedL1, selectedL2: selectedL2);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: categoriesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('Error: $e')),
                data: (allCategories) {
                  final l1Categories = allCategories
                      .where((c) => c.parentId == null)
                      .toList();
                  final l2Categories = selectedL1 == null
                      ? <Category>[]
                      : allCategories
                            .where((c) => c.parentId == selectedL1.id)
                            .toList();
                  final l3Categories = selectedL2 == null
                      ? <Category>[]
                      : allCategories
                            .where((c) => c.parentId == selectedL2.id)
                            .toList();

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 대분류 (L1)
                      Expanded(
                        child: _CategoryColumn(
                          title: '대분류 (${l1Categories.length})',
                          categories: l1Categories,
                          selectedCategory: selectedL1,
                          onCategorySelected: (category) {
                            ref
                                    .read(selectedL1CategoryProvider.notifier)
                                    .state =
                                category;
                            ref
                                    .read(selectedL2CategoryProvider.notifier)
                                    .state =
                                null; // 중분류 선택 초기화
                          },
                        ),
                      ),
                      const VerticalDivider(),
                      // 중분류 (L2)
                      Expanded(
                        child: _CategoryColumn(
                          title: '중분류 (${l2Categories.length})',
                          categories: l2Categories,
                          selectedCategory: selectedL2,
                          onCategorySelected: (category) {
                            ref
                                    .read(selectedL2CategoryProvider.notifier)
                                    .state =
                                category;
                          },
                        ),
                      ),
                      const VerticalDivider(),
                      // 소분류 (L3)
                      Expanded(
                        child: _CategoryColumn(
                          title: '소분류 (${l3Categories.length})',
                          categories: l3Categories,
                          selectedCategory: null, // 소분류는 선택 상태 없음
                          onCategorySelected: (category) {
                            // 소분류 선택 시 특별한 동작 없음
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 카테고리 추가/수정 다이얼로그
  void _showCategoryDialog(
    BuildContext context,
    WidgetRef ref, {
    Category? existingCategory,
    Category? selectedL1, 
    Category? selectedL2
  }) {
    final viewModel = ref.read(categoryViewModelProvider.notifier);
    final isEditing = existingCategory != null;
    final nameController = TextEditingController(
      text: existingCategory?.name ?? '',
    );
  final allCategories = ref.read(categoriesProvider).value ?? [];

  final levelProvider = StateProvider.autoDispose<int>((_) {
      if (isEditing) { // 수정 모드일 때
        if (existingCategory.parentId == null) return 1;
        final parent = allCategories.firstWhere((c) => c.id == existingCategory.parentId);
        return parent.parentId == null ? 2 : 3;
      }
      // 💡 생성 모드일 때, 선택된 카테고리에 따라 초기 레벨 결정
      if (selectedL2 != null) return 3; // 중분류가 선택되어 있으면 -> 소분류 추가
      if (selectedL1 != null) return 2; // 대분류가 선택되어 있으면 -> 중분류 추가
      return 1; // 아무것도 선택 안됐으면 -> 대분류 추가
    });
  
  final parentL1Provider = StateProvider.autoDispose<Category?>((_) {
    if (isEditing) {
        if (existingCategory.parentId == null) return null;
        final parent = allCategories.firstWhere((c) => c.id == existingCategory.parentId);
        return parent.parentId == null ? parent : allCategories.firstWhere((c) => c.id == parent.parentId);
      }
      // 💡 생성 모드일 때, 선택된 대분류를 초기값으로 설정
      return selectedL1;
    });

  final parentL2Provider = StateProvider.autoDispose<Category?>((_) {
    if (isEditing) {
        if (existingCategory.parentId == null) return null;
        final parent = allCategories.firstWhere((c) => c.id == existingCategory.parentId);
        return parent.parentId != null ? parent : null;
      }
      // 💡 생성 모드일 때, 선택된 중분류를 초기값으로 설정
      return selectedL2;
    });

showDialog(
    context: context,
    builder: (context) {
      return Consumer(builder: (context, ref, child) {
        final level = ref.watch(levelProvider);
        final parentL1 = ref.watch(parentL1Provider);
        final parentL2 = ref.watch(parentL2Provider);

        final l1Categories = allCategories.where((c) => c.parentId == null).toList();
        final l2Categories = parentL1 == null ? <Category>[] : allCategories.where((c) => c.parentId == parentL1.id).toList();

        return AlertDialog(
          title: Text(isEditing ? '카테고리 수정' : '새 카테고리 추가'),
          content: SizedBox(
            width: 400, // 다이얼로그 너비 고정
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 수정 모드에서는 레벨 변경 불가
                  if (!isEditing) ...[
                    Text('분류 선택', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 1, label: Text('대분류')),
                        ButtonSegment(value: 2, label: Text('중분류')),
                        ButtonSegment(value: 3, label: Text('소분류')),
                      ],
                      selected: {level},
                      onSelectionChanged: (newSelection) {
                        ref.read(levelProvider.notifier).state = newSelection.first;
                      },
                    ),
                    const SizedBox(height: 24),
                  ],

                  if (level >= 2)
                    DropdownButtonFormField<Category>(
                      value: parentL1,
                      hint: const Text('상위 대분류 선택'),
                      items: l1Categories.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                      onChanged: isEditing ? null : (value) { // 수정 모드에서는 부모 변경 불가
                        ref.read(parentL1Provider.notifier).state = value;
                        ref.read(parentL2Provider.notifier).state = null;
                      },
                      decoration: InputDecoration(enabled: !isEditing), // 비활성화 시 시각적 표시
                    ),

                  if (level == 3) ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Category>(
                      value: parentL2,
                      hint: const Text('상위 중분류 선택'),
                      items: l2Categories.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                      onChanged: isEditing ? null : (value) {
                        ref.read(parentL2Provider.notifier).state = value;
                      },
                      decoration: InputDecoration(enabled: !isEditing),
                    ),
                  ],

                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: '${['대', '중', '소'][level - 1]}분류 이름'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('취소')),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text;
                if (name.isEmpty) return;

                int? parentId;
                if (level == 2) parentId = parentL1?.id;
                if (level == 3) parentId = parentL2?.id;

                if (isEditing) {
                  await viewModel.updateCategory(
                    id: existingCategory.id,
                    name: name,
                    parentId: existingCategory.parentId, // 수정 시에는 부모 ID 변경 안 함
                  );
                } else {
                  await viewModel.createCategory(
                    name: name,
                    parentId: parentId,
                  );
                }
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('저장'),
            ),
          ],
        );
      });
    },
  );
}
}

/// 카테고리 컬럼 UI를 위한 별도 위젯
class _CategoryColumn extends ConsumerWidget {
  final String title;
  final List<Category> categories;
  final Category? selectedCategory;
  final ValueChanged<Category> onCategorySelected;

  const _CategoryColumn({
    required this.title,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        const Divider(height: 1),
        Expanded(
          child: categories.isEmpty
              ? const Center(
                  child: Text('항목 없음', style: TextStyle(color: Colors.grey)),
                )
              : ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return ListTile(
                      title: Text(category.name),
                      selected: selectedCategory?.id == category.id,
                      selectedTileColor: Colors.blue.withOpacity(0.1),
                      onTap: () => onCategorySelected(category),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              size: 20,
                              color: Colors.grey,
                            ),
                            tooltip: '수정',
                            onPressed: () {
                              // CategoryManagementScreen의 _showCategoryDialog를 직접 호출할 수 없으므로,
                              // ref를 통해 이벤트를 전달하거나 다른 방식으로 호출해야 합니다.
                              // 지금 구조에서는 이 클래스를 CategoryManagementScreen 내부로 옮기는 것이 좋습니다.
                              // 하지만 우선은 기능 시연을 위해 동작하지 않는 버튼으로 둡니다.
                              // => 해결책: _showCategoryDialog를 build 메소드 바깥으로 빼서 static처럼 사용.
                              (context as Element)
                                  .findAncestorWidgetOfExactType<
                                    CategoryManagementScreen
                                  >()
                                  ?._showCategoryDialog(
                                    context,
                                    ref,
                                    existingCategory: category,
                                  );
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              size: 20,
                              color: Colors.redAccent,
                            ),
                            tooltip: '삭제',
                            onPressed: () async {
                              final confirm = await _showDeleteConfirmDialog(
                                context,
                              );
                              if (confirm == true) {
                                await ref
                                    .read(categoryViewModelProvider.notifier)
                                    .deleteCategory(category.id);
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // 삭제 확인 다이얼로그
  Future<bool?> _showDeleteConfirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('카테고리 삭제'),
        content: const Text(
          '정말로 이 카테고리를 삭제하시겠습니까? 하위 카테고리가 있는 경우 함께 삭제할 수 없습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}
