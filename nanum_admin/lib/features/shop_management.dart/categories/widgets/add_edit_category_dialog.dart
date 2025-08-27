// admin_web/lib/features/shop_management/categories/widgets/add_edit_category_dialog.dart (새 파일)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/category_model.dart';
import '../viewmodel/category_viewmodel.dart';

class AddEditCategoryDialog extends ConsumerStatefulWidget {
  final int? parentId;
  final CategoryModel? categoryToEdit;

  const AddEditCategoryDialog({
    super.key,
    this.parentId,
    this.categoryToEdit,
  });

  @override
  ConsumerState<AddEditCategoryDialog> createState() =>
      _AddEditCategoryDialogState();
}

class _AddEditCategoryDialogState extends ConsumerState<AddEditCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  bool get _isEditMode => widget.categoryToEdit != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.categoryToEdit?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final viewModel = ref.read(categoriesProvider.notifier);
      final name = _nameController.text;

      if (_isEditMode) {
        final updatedCategory = CategoryModel(
          id: widget.categoryToEdit!.id,
          name: name,
          createdAt: widget.categoryToEdit!.createdAt,
          parentId: widget.categoryToEdit!.parentId,
        );
        viewModel.updateCategory(updatedCategory);
      } else {
        viewModel.addCategory(name: name, parentId: widget.parentId);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = '새 최상위 카테고리';
    if (_isEditMode) {
      title = '카테고리 이름 수정';
    } else if (widget.parentId != null) {
      title = '새 하위 카테고리';
    }

    return AlertDialog(
      title: Text(title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          autofocus: true,
          decoration: const InputDecoration(labelText: '카테고리 이름'),
          validator: (value) =>
              (value == null || value.isEmpty) ? '필수 항목입니다.' : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(_isEditMode ? '수정' : '저장'),
        ),
      ],
    );
  }
}