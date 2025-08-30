// admin_web/lib/features/shop_management/products/view/add_edit_product_screen.dart (전체 코드)

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../data/models/category_model.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/models/product_variant_model.dart';
import '../../../../data/repositories/product_repository.dart';
import '../../categories/viewmodel/category_viewmodel.dart';
import '../viewmodel/product_viewmodel.dart';

class AddEditProductScreen extends ConsumerStatefulWidget {
  final ProductModel? productToEdit;

  const AddEditProductScreen({
    super.key,
    this.productToEdit,
  });

  @override
  ConsumerState<AddEditProductScreen> createState() =>
      _AddEditProductScreenState();
}

class _AddEditProductScreenState extends ConsumerState<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _productCodeController;
  late TextEditingController _relatedProductCodeController;
  late TextEditingController _shippingFeeController;

  // ⭐️ 태그 상태를 관리할 맵
  Map<String, bool> _tags = {
    'is_hit': false,
    'is_recommended': false,
    'is_new': false,
    'is_popular': false,
    'is_discount': false,
  };

  XFile? _selectedImageFile;
  Uint8List? _selectedImageBytes;
  String? _existingImageUrl;

  int? _level1CategoryId;
  int? _level2CategoryId;
  int? _level3CategoryId;
  List<CategoryModel> _level2Categories = [];
  List<CategoryModel> _level3Categories = [];

  List<OptionGroup> _optionGroups = [];
  List<ProductVariant> _variants = [];

  bool _isDisplayed = true;
  bool _isSoldOut = false;

  bool get _isEditMode => widget.productToEdit != null;

  // ⭐️ 2. 옵션 값 입력을 위한 컨트롤러와 포커스 노드 리스트 추가
  List<TextEditingController> _optionValueControllers = [];
  List<FocusNode> _optionValueFocusNodes = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.productToEdit?.name ?? '');
    _descController = TextEditingController(text: widget.productToEdit?.description ?? '');
    _priceController = TextEditingController(text: widget.productToEdit?.price.toString() ?? '');
    _stockController = TextEditingController(text: widget.productToEdit?.stockQuantity.toString() ?? '');
    _productCodeController = TextEditingController(text: widget.productToEdit?.productCode ?? '');
    _relatedProductCodeController = TextEditingController(text: widget.productToEdit?.relatedProductCode ?? '');
    _existingImageUrl = widget.productToEdit?.imageUrl;
    _isDisplayed = widget.productToEdit?.isDisplayed ?? true;
    _isSoldOut = widget.productToEdit?.isSoldOut ?? false;

    _shippingFeeController = TextEditingController(text: widget.productToEdit?.shippingFee.toString() ?? '3000');
    if (widget.productToEdit != null) {
      _tags = widget.productToEdit!.tags;
    }

    
// ⭐️ 수정 모드일 경우, 기존 옵션과 조합 정보를 불러옵니다.
  if (_isEditMode) {
    // ref는 initState에서 직접 사용할 수 없으므로, ConsumerStatefulWidget의 ref를 사용합니다.
    // addPostFrameCallback을 사용하여 build가 완료된 후 데이터를 안전하게 불러옵니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productRepositoryProvider)
         .fetchOptionsAndVariants(widget.productToEdit!.id)
         .then((data) {
            // 위젯이 아직 화면에 있을 때만 state를 업데이트합니다.
            if (mounted) {
              setState(() {
                _optionGroups = data.$1; // Tuple의 첫 번째 요소 (List<OptionGroup>)
                _variants = data.$2;   // Tuple의 두 번째 요소 (List<ProductVariant>)
                _initializeControllers(); // 불러온 옵션 그룹 수만큼 컨트롤러 초기화
              });
            }
         });
    });
  }
}

// ⭐️ 컨트롤러/포커스 노드를 관리하는 함수들
  void _initializeControllers() {
    _optionValueControllers = List.generate(_optionGroups.length, (_) => TextEditingController());
    _optionValueFocusNodes = List.generate(_optionGroups.length, (_) => FocusNode());
  }

  void _addOptionGroup() {
    setState(() {
      _optionGroups.add(OptionGroup(name: '', values: []));
      _optionValueControllers.add(TextEditingController());
      _optionValueFocusNodes.add(FocusNode());
    });

    
  }

  void _removeOptionGroup(int index) {
    setState(() {
      _optionGroups.removeAt(index);
      _optionValueControllers.removeAt(index).dispose();
      _optionValueFocusNodes.removeAt(index).dispose();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _productCodeController.dispose();
    _relatedProductCodeController.dispose();
    _shippingFeeController.dispose();
    // ⭐️ 동적으로 생성된 컨트롤러와 포커스 노드 모두 정리
    for (var controller in _optionValueControllers) {
      controller.dispose();
    }
    for (var node in _optionValueFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }
  

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

  int? get _finalCategoryId {
    return _level3CategoryId ?? _level2CategoryId ?? _level1CategoryId;
  }

  void _generateVariants() {
    if (_optionGroups.isEmpty) {
      setState(() => _variants = []);
      return;
    }

    List<List<String>> allValues = _optionGroups
        .map((group) => group.values.map((v) => v.value).toList())
        .where((list) => list.isNotEmpty) // 빈 값 리스트는 제외
        .toList();

    if (allValues.isEmpty) {
        setState(() => _variants = []);
        return;
    }

    List<String> combinations = allValues.fold<List<String>>(
      [''], (previous, element) {
        return previous.expand((p) => element.map((e) => p.isEmpty ? e : '$p / $e')).toList();
      }
    );

    setState(() {
      _variants = combinations.map((name) => ProductVariant(name: name)).toList();
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_finalCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('카테고리를 선택해주세요.'), backgroundColor: Colors.red));
        return;
      }
      if (_optionGroups.isNotEmpty && _variants.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('옵션을 정의한 후, 반드시 "옵션 조합 생성" 버튼을 눌러주세요.'),
            backgroundColor: Colors.red,
        ));
        return;
      }

      final viewModel = ref.read(productViewModelProvider.notifier);

      if (_isEditMode) {
        final updatedProduct = widget.productToEdit!.copyWith(
          name: _nameController.text,
          description: _descController.text,
          price: int.parse(_priceController.text),
          stockQuantity: int.parse(_stockController.text),
          categoryId: _finalCategoryId,
          isDisplayed: _isDisplayed,
          isSoldOut: _isSoldOut,
          productCode: _productCodeController.text.trim(),
          relatedProductCode: _relatedProductCodeController.text.trim(),
          shippingFee: int.parse(_shippingFeeController.text),
          tags: _tags,
        );
        viewModel.updateProductWithOptions(
          updatedProduct,
          optionGroups: _optionGroups,
          variants: _variants,
          newImageFile: _selectedImageFile,
        );
      } else {
        viewModel.addProduct(
          name: _nameController.text,
          description: _descController.text,
          price: int.parse(_priceController.text),
          stockQuantity: int.parse(_stockController.text),
          categoryId: _finalCategoryId!,
          isDisplayed: _isDisplayed,
          isSoldOut: _isSoldOut,
          imageFile: _selectedImageFile,
          productCode: _productCodeController.text.trim(),
          relatedProductCode: _relatedProductCodeController.text.trim(),
          optionGroups: _optionGroups,
          variants: _variants,
          shippingFee: int.parse(_shippingFeeController.text),
          tags: _tags,
        );
      }
      context.go('/shop/products');
    }
  }

  

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? '상품 수정' : '새 상품 등록'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/shop/products'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: '저장',
            onPressed: _submit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: categoriesAsync.when(
              data: (allCategories) {
                if (_isEditMode && _level1CategoryId == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _findCategoryPath(widget.productToEdit!.categoryId, allCategories);
                      setState(() {});
                    }
                  });
                }
                return _buildForm(allCategories);
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, st) => Text('카테고리를 불러올 수 없습니다: $e'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(List<CategoryModel> allCategories) {

    final Map<String, String> tagMap = {
      'is_hit': '히트',
      'is_recommended': '추천',
      'is_new': '신상',
      'is_popular': '인기',
      'is_discount': '할인',
    };
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 150,
            width: 150,
            decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
            child: _selectedImageBytes != null
                ? Image.memory(_selectedImageBytes!, fit: BoxFit.cover)
                : (_existingImageUrl != null && _existingImageUrl!.isNotEmpty
                    ? Image.network(_existingImageUrl!, fit: BoxFit.cover)
                    : const Center(child: Text('이미지 없음'))),
          ),
          TextButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.upload_file),
            label: const Text('이미지 선택'),
          ),
          const SizedBox(height: 16),
          TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: '상품명'), validator: (v) => v!.isEmpty ? '필수 항목입니다.' : null),
          const SizedBox(height: 16),
          _buildCategoryDropdown(
            hint: '1차 카테고리',
            value: _level1CategoryId,
            items: allCategories,
            onChanged: (value) {
              setState(() {
                _level1CategoryId = value;
                _level2CategoryId = null;
                _level3CategoryId = null;
                _level2Categories = allCategories.firstWhere((c) => c.id == value).children;
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
          const SizedBox(height: 16),
          TextFormField(controller: _priceController, decoration: const InputDecoration(labelText: '가격'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? '필수 항목입니다.' : null),
          const SizedBox(height: 16),
          // ⭐️ 배송비 입력 필드 추가
          TextFormField(
            controller: _shippingFeeController,
            decoration: const InputDecoration(labelText: '배송비'),
            keyboardType: TextInputType.number,
            validator: (v) => v!.isEmpty ? '필수 항목입니다.' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(controller: _stockController, decoration: const InputDecoration(labelText: '재고 (옵션이 없을 경우)'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty && _optionGroups.isEmpty ? '필수 항목입니다.' : null),
          const SizedBox(height: 16),
          TextFormField(controller: _descController, decoration: const InputDecoration(labelText: '상세 설명 (선택)')),
          const SizedBox(height: 16),
          TextFormField(controller: _productCodeController, decoration: const InputDecoration(labelText: '상품 코드 (선택)')),
          const SizedBox(height: 16),
          TextFormField(controller: _relatedProductCodeController, decoration: const InputDecoration(labelText: '연관 상품 코드 (선택)')),
          const Divider(height: 48),
          // ⭐️ 3. 상품 태그 설정 UI를 Wrap 위젯으로 변경합니다.
          Text('상품 태그 설정', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0, // 가로 간격
            runSpacing: 4.0, // 세로 간격
            children: tagMap.entries.map((entry) {
              final key = entry.key;
              final title = entry.value;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _tags[key] ?? false,
                    onChanged: (bool? value) {
                      setState(() {
                        _tags[key] = value ?? false;
                      });
                    },
                  ),
                  Text(title),
                ],
              );
            }).toList(),
          ),
          

          const Divider(height: 48),
          _buildOptionDefinitionUI(),
          const SizedBox(height: 24),
          if (_optionGroups.isNotEmpty)
            ElevatedButton.icon(
              icon: const Icon(Icons.sync),
              label: const Text('옵션 조합 생성'),
              onPressed: _generateVariants,
            ),
          const SizedBox(height: 24),
          if (_variants.isNotEmpty) _buildVariantEditorUI(),
          const Divider(height: 48),
          SwitchListTile(title: const Text('쇼핑몰에 진열'), value: _isDisplayed, onChanged: (v) => setState(() => _isDisplayed = v)),
          SwitchListTile(title: const Text('품절 처리 (옵션이 없을 경우)'), value: _isSoldOut, onChanged: (v) => setState(() => _isSoldOut = v)),
        ],
      ),
    );
  }

  

  
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
      ),
    );
  }

  void _findCategoryPath(int categoryId, List<CategoryModel> allCategories) {
      for (var l1Cat in allCategories) {
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

  Widget _buildOptionDefinitionUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('옵션 설정', style: Theme.of(context).textTheme.titleLarge),
        ..._optionGroups.asMap().entries.map((entry) {
          int index = entry.key;
          OptionGroup group = entry.value;
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: group.name,
                          decoration: InputDecoration(labelText: '옵션 그룹명 (예: 색상)'),
                          onChanged: (value) => group.name = value,
                        ),
                      ),
                      // ⭐️ 1. '옵션 그룹 삭제' 버튼이 _removeOptionGroup 함수를 호출합니다.
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                        onPressed: () => _removeOptionGroup(index),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: group.values.map((v) => Chip(
                      label: Text(v.value),
                      onDeleted: () => setState(() => group.values.remove(v)),
                    )).toList(),
                  ),
                  TextFormField(
                    // ⭐️ 컨트롤러와 포커스 노드 연결
                    controller: _optionValueControllers[index],
                    focusNode: _optionValueFocusNodes[index],
                    decoration: InputDecoration(labelText: '옵션 값 추가 (입력 후 Enter)'),
                    onFieldSubmitted: (value) {
                      if (value.isNotEmpty) {
                        setState(() {
                          group.values.add(OptionValue(value: value));
                          // ⭐️ 입력 필드 비우기
                          _optionValueControllers[index].clear();
                          // ⭐️ 다시 포커스 주기
                          _optionValueFocusNodes[index].requestFocus();
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        }),
        if (_optionGroups.length < 3) // 옵션 그룹은 최대 3개까지만
          TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('옵션 그룹 추가'),
            onPressed: _addOptionGroup,
          )
      ],
    );
  }

  Widget _buildVariantEditorUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('옵션 조합 관리', style: Theme.of(context).textTheme.titleLarge),
        DataTable(
          columns: const [
            DataColumn(label: Text('옵션명')),
            DataColumn(label: Text('추가금액')),
            DataColumn(label: Text('재고')),
          ],
          rows: _variants.map((variant) {
            return DataRow(cells: [
              DataCell(Text(variant.name)),
              DataCell(TextFormField(
                initialValue: variant.additionalPrice.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(prefixText: '+', suffixText: '원'),
                onChanged: (v) => variant.additionalPrice = int.tryParse(v) ?? 0,
              )),
              DataCell(TextFormField(
                initialValue: variant.stockQuantity.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(suffixText: '개'),
                onChanged: (v) => variant.stockQuantity = int.tryParse(v) ?? 0,
              )),
            ]);
          }).toList(),
        )
      ],
    );
  }
}