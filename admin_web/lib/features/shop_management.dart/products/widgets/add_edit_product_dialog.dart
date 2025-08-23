// admin_web/lib/features/shop_management/products/widgets/add_edit_product_dialog.dart (새 파일)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/models/product_model.dart';
import '../viewmodel/product_viewmodel.dart';

class AddEditProductDialog extends ConsumerStatefulWidget {
  final List<CategoryModel> categories;
  // ⭐️ '수정'일 경우 이 파라미터로 기존 상품 데이터가 전달됩니다.
  final ProductModel? productToEdit;

  const AddEditProductDialog({
    super.key,
    required this.categories,
    this.productToEdit,
  });

  @override
  ConsumerState<AddEditProductDialog> createState() =>
      _AddEditProductDialogState();
}

class _AddEditProductDialogState extends ConsumerState<AddEditProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  int? _selectedCategoryId;
  bool _isDisplayed = true;

  // ⭐️ '수정' 모드인지 확인하는 변수
  bool get _isEditMode => widget.productToEdit != null;

  @override
  void initState() {
    super.initState();
    // ⭐️ 수정 모드일 경우, 기존 데이터로 폼을 채웁니다.
    _nameController = TextEditingController(text: widget.productToEdit?.name ?? '');
    _descController = TextEditingController(text: widget.productToEdit?.description ?? '');
    _priceController = TextEditingController(text: widget.productToEdit?.price.toString() ?? '');
    _stockController = TextEditingController(text: widget.productToEdit?.stockQuantity.toString() ?? '');
    _selectedCategoryId = widget.productToEdit?.categoryId;
    _isDisplayed = widget.productToEdit?.isDisplayed ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final viewModel = ref.read(productViewModelProvider.notifier);
      
      // ⭐️ 수정 모드와 등록 모드를 구분하여 다른 메서드 호출
      if (_isEditMode) {
        final updatedProduct = widget.productToEdit!.copyWith(
          name: _nameController.text,
          description: _descController.text,
          price: int.parse(_priceController.text),
          stockQuantity: int.parse(_stockController.text),
          categoryId: _selectedCategoryId!,
          isDisplayed: _isDisplayed,
        );
        viewModel.updateProduct(updatedProduct);
      } else {
        viewModel.addProduct(
          name: _nameController.text,
          description: _descController.text,
          price: int.parse(_priceController.text),
          stockQuantity: int.parse(_stockController.text),
          categoryId: _selectedCategoryId!,
          isDisplayed: _isDisplayed,
        );
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditMode ? '상품 수정' : '새 상품 등록'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: SizedBox(
            width: 400, // 다이얼로그 폭 지정
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ... (TextFormField, DropdownButtonFormField 등 나머지 UI 코드는 이전과 동일)
                TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: '상품명'), validator: (v) => v!.isEmpty ? '필수' : null),
                DropdownButtonFormField<int>(
                    value: _selectedCategoryId,
                    hint: const Text('카테고리 선택'),
                    items: widget.categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                    onChanged: (v) => setState(() => _selectedCategoryId = v),
                    validator: (v) => v == null ? '필수' : null,
                ),
                TextFormField(controller: _priceController, decoration: const InputDecoration(labelText: '가격'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? '필수' : null),
                TextFormField(controller: _stockController, decoration: const InputDecoration(labelText: '재고'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? '필수' : null),
                TextFormField(controller: _descController, decoration: const InputDecoration(labelText: '상세 설명'), maxLines: 3),
                SwitchListTile(title: const Text('쇼핑몰에 진열'), value: _isDisplayed, onChanged: (v) => setState(() => _isDisplayed = v)),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('취소')),
        ElevatedButton(onPressed: _submit, child: Text(_isEditMode ? '수정' : '저장')),
      ],
    );
  }
}