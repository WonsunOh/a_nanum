// admin_web/lib/features/shop_management/products/widgets/add_edit_product_dialog.dart (새 파일)

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/models/product_model.dart';
import '../viewmodel/product_viewmodel.dart';

class AddEditProductDialog extends ConsumerStatefulWidget {
  final List<CategoryModel> categories; // 최상위 카테고리 리스트
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
  late TextEditingController _productCodeController;
  late TextEditingController _relatedProductCodeController;
  bool _isDisplayed = true;
   // ⭐️ 이미지 데이터를 관리할 상태 변수들
  XFile? _selectedImageFile;
  Uint8List? _selectedImageBytes;
  String? _existingImageUrl;



  // ⭐️ 3단계 선택을 위한 상태 변수들
  int? _level1CategoryId;
  int? _level2CategoryId;
  int? _level3CategoryId;

  // ⭐️ 각 레벨별 카테고리 리스트
  List<CategoryModel> _level2Categories = [];
  List<CategoryModel> _level3Categories = [];

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
     _productCodeController = TextEditingController(text: widget.productToEdit?.productCode ?? '');
    _relatedProductCodeController = TextEditingController(text: widget.productToEdit?.relatedProductCode ?? '');
    _isDisplayed = widget.productToEdit?.isDisplayed ?? true;
     _existingImageUrl = widget.productToEdit?.imageUrl;

    // ⭐️ 수정 모드일 경우, 3단계 카테고리 경로를 찾아 상태를 복원합니다.
    if (_isEditMode && widget.productToEdit != null) {
      _findCategoryPath(widget.productToEdit!.categoryId);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
     _productCodeController.dispose();
    _relatedProductCodeController.dispose();
    super.dispose();
  }

  // ⭐️ 이미지 선택 로직
  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final file = await imagePicker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() {
        _selectedImageFile = file;
        _selectedImageBytes = bytes;
      });
    }
  }


   // ⭐️ 최종적으로 선택된 카테고리 ID를 반환하는 getter
  int? get _selectedCategoryId {
      return _level3CategoryId ?? _level2CategoryId ?? _level1CategoryId;
  }
  
  // ⭐️ 카테고리 경로를 찾는 함수
  void _findCategoryPath(int categoryId) {
      for (var l1Cat in widget.categories) {
          if (l1Cat.id == categoryId) {
              _level1CategoryId = l1Cat.id;
              return;
          }
          for (var l2Cat in l1Cat.children) {
              if (l2Cat.id == categoryId) {
                  _level1CategoryId = l1Cat.id;
                  _level2Categories = l1Cat.children;
                  _level2CategoryId = l2Cat.id;
                  return;
              }
              for (var l3Cat in l2Cat.children) {
                  if (l3Cat.id == categoryId) {
                      _level1CategoryId = l1Cat.id;
                      _level2Categories = l1Cat.children;
                      _level2CategoryId = l2Cat.id;
                      _level3Categories = l2Cat.children;
                      _level3CategoryId = l3Cat.id;
                      return;
                  }
              }
          }
      }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final viewModel = ref.read(productViewModelProvider.notifier);
      
      // ⭐️ 수정 모드와 등록 모드를 구분하여 다른 메서드 호출
      if (_isEditMode) {
        // ⭐️ 1. 폼에 입력된 모든 내용으로 '최종 수정본'을 만듭니다.
      final updatedProduct = widget.productToEdit!.copyWith(
        name: _nameController.text,
        description: _descController.text,
        price: int.parse(_priceController.text),
        stockQuantity: int.parse(_stockController.text),
        categoryId: _selectedCategoryId!,
        isDisplayed: _isDisplayed,
        productCode: _productCodeController.text,
        relatedProductCode: _relatedProductCodeController.text,
      );
      // ⭐️ 2. '최종 수정본'과 '새 이미지 파일'을 ViewModel에 전달합니다.
      viewModel.updateProduct(
        updatedProduct,
        newImageFile: _selectedImageFile,
      );
      } else {
        viewModel.addProduct(
          name: _nameController.text,
          description: _descController.text,
          price: int.parse(_priceController.text),
          stockQuantity: int.parse(_stockController.text),
          productCode: _productCodeController.text,
          relatedProductCode: _relatedProductCodeController.text,
          categoryId: _selectedCategoryId!,
          isDisplayed: _isDisplayed,
          imageFile: _selectedImageFile,
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
            width: 500, // 다이얼로그 폭 지정
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _productCodeController,
                  decoration: const InputDecoration(labelText: '상품 코드 (선택)'),
                ),
                // ⭐️ 연관 상품 코드 입력 필드 추가
                TextFormField(
                  controller: _relatedProductCodeController,
                  decoration: const InputDecoration(labelText: '연관 상품 코드 (선택)'),
                ),
                TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: '상품명'), validator: (v) => v!.isEmpty ? '필수' : null),
                // ⭐️ 3단계 카테고리 선택 UI
                _buildCategoryDropdown(
                  hint: '1차 카테고리',
                  value: _level1CategoryId,
                  items: widget.categories,
                  onChanged: (value) {
                    setState(() {
                      _level1CategoryId = value;
                      _level2CategoryId = null;
                      _level3CategoryId = null;
                      _level2Categories = widget.categories.firstWhere((c) => c.id == value).children;
                      _level3Categories = [];
                    });
                  },
                ),
                if (_level1CategoryId != null && _level2Categories.isNotEmpty)
                  _buildCategoryDropdown(
                    hint: '2차 카테고리',
                    value: _level2CategoryId,
                    items: _level2Categories,
                    onChanged: (value) {
                      setState(() {
                        _level2CategoryId = value;
                        _level3CategoryId = null;
                        _level3Categories = _level2Categories.firstWhere((c) => c.id == value).children;
                      });
                    },
                  ),
                if (_level2CategoryId != null && _level3Categories.isNotEmpty)
                  _buildCategoryDropdown(
                    hint: '3차 카테고리',
                    value: _level3CategoryId,
                    items: _level3Categories,
                    onChanged: (value) {
                      setState(() {
                        _level3CategoryId = value;
                      });
                    },
                  ),
                Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _selectedImageBytes != null
                      ? Image.memory(_selectedImageBytes!, fit: BoxFit.cover)
                      : (_existingImageUrl != null
                          ? Image.network(_existingImageUrl!, fit: BoxFit.cover)
                          : const Center(child: Text('이미지 없음'))),
                ),
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('이미지 선택'),
                ),
                TextFormField(controller: _priceController, decoration: const InputDecoration(labelText: '가격'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? '필수' : null),
                TextFormField(controller: _stockController, decoration: const InputDecoration(labelText: '재고'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? '필수' : null),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: '상세 설명 (선택)'),
                  maxLines: 3,
                ),
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
 // ⭐️ 드롭다운 위젯을 만드는 공통 함수
  Widget _buildCategoryDropdown({
    required String hint,
    required int? value,
    required List<CategoryModel> items,
    required ValueChanged<int?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<int>(
        value: value,
        hint: Text(hint),
        items: items.map((category) {
          return DropdownMenuItem(
            value: category.id,
            child: Text(category.name),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) => items.isNotEmpty && value == null ? '필수 항목입니다.' : null,
      ),
    );
  }
}