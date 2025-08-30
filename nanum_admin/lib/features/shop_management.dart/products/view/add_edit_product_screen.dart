// admin_web/lib/features/shop_management/products/view/add_edit_product_screen.dart (최종 수정)

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

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
  late QuillController _quillController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _productCodeController;
  late TextEditingController _relatedProductCodeController;
  late TextEditingController _shippingFeeController;
  late TextEditingController _discountPriceController;
   // ⭐️ 1. 할인 기간을 저장할 변수 추가
  DateTime? _discountStartDate;
  DateTime? _discountEndDate;

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

  List<TextEditingController> _optionValueControllers = [];
  List<FocusNode> _optionValueFocusNodes = [];

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.productToEdit?.name ?? '');

    _initializeQuillController();

    _priceController =
        TextEditingController(text: widget.productToEdit?.price.toString() ?? '');
    _stockController = TextEditingController(
        text: widget.productToEdit?.stockQuantity.toString() ?? '');
    _productCodeController =
        TextEditingController(text: widget.productToEdit?.productCode ?? '');
    _relatedProductCodeController = TextEditingController(
        text: widget.productToEdit?.relatedProductCode ?? '');
    _existingImageUrl = widget.productToEdit?.imageUrl;
    _isDisplayed = widget.productToEdit?.isDisplayed ?? true;
    _isSoldOut = widget.productToEdit?.isSoldOut ?? false;
    _discountPriceController = TextEditingController(
      text: widget.productToEdit?.discountPrice?.toString() ?? '');

    _shippingFeeController = TextEditingController(
        text: widget.productToEdit?.shippingFee.toString() ?? '3000');
    if (widget.productToEdit != null) {
      _tags = widget.productToEdit!.tags;
    }

    _discountPriceController = TextEditingController(
      text: widget.productToEdit?.discountPrice?.toString() ?? '');
  

    if (_isEditMode) {
      _discountStartDate = widget.productToEdit?.discountStartDate;
    _discountEndDate = widget.productToEdit?.discountEndDate;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref
            .read(productRepositoryProvider)
            .fetchOptionsAndVariants(widget.productToEdit!.id)
            .then((data) {
          if (mounted) {
            setState(() {
              _optionGroups = data.$1;
              _variants = data.$2;
              _initializeControllers();
            });
          }
        });
      });
    }
  }

  void _initializeQuillController() {
    final description = widget.productToEdit?.description;
    if (description != null &&
        description.isNotEmpty &&
        description.trimLeft().startsWith('[')) {
      try {
        final doc = Document.fromJson(jsonDecode(description));
        _quillController = QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        final doc = Document()..insert(0, description);
        _quillController = QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
        );
      }
    } else {
      final doc = Document()..insert(0, description ?? '');
      _quillController = QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
    }
  }

  void _initializeControllers() {
    _optionValueControllers =
        List.generate(_optionGroups.length, (_) => TextEditingController());
    _optionValueFocusNodes =
        List.generate(_optionGroups.length, (_) => FocusNode());
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
    _quillController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _productCodeController.dispose();
    _relatedProductCodeController.dispose();
    _shippingFeeController.dispose();
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
  
  // Quill 에디터의 이미지 업로드를 처리하는 콜백 함수
  Future<String?> _onImagePickCallback(XFile file) async {
    final imageBytes = await file.readAsBytes();
  final imageName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    
    try {
      await Supabase.instance.client.storage
          .from('products')
          .uploadBinary(imageName, imageBytes);
      
      final imageUrl = Supabase.instance.client.storage
          .from('products')
          .getPublicUrl(imageName);
          
      return imageUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지 업로드 실패: $e'), backgroundColor: Colors.red),
        );
      }
      // ⭐️ 3. 에러 발생 시에도 null을 반환합니다.
      return null;
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
        .where((list) => list.isNotEmpty)
        .toList();

    if (allValues.isEmpty) {
      setState(() => _variants = []);
      return;
    }
    List<String> combinations = allValues.fold<List<String>>([''],
        (previous, element) {
      return previous
          .expand((p) => element.map((e) => p.isEmpty ? e : '$p / $e'))
          .toList();
    });

    setState(() {
      _variants =
          combinations.map((name) => ProductVariant(name: name)).toList();
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_finalCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('카테고리를 선택해주세요.'), backgroundColor: Colors.red));
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
      final descriptionJson =
          jsonEncode(_quillController.document.toDelta().toJson());
      final discountPrice = int.tryParse(_discountPriceController.text);

      // ⭐️ [데이터 추적 1단계] View에서 ViewModel으로 데이터를 보내기 직전 값 확인
      debugPrint('--- [VIEW] Submitting Data ---');
      debugPrint('Discount Start Date: $_discountStartDate');
      debugPrint('Discount End Date: $_discountEndDate');
      debugPrint('-----------------------------');

      if (_isEditMode) {
        final updatedProduct = widget.productToEdit!.copyWith(
          name: _nameController.text,
          description: descriptionJson,
          price: int.parse(_priceController.text),
          stockQuantity: int.parse(_stockController.text),
          categoryId: _finalCategoryId,
          isDisplayed: _isDisplayed,
          isSoldOut: _isSoldOut,
          productCode: _productCodeController.text.trim(),
          relatedProductCode: _relatedProductCodeController.text.trim(),
          shippingFee: int.parse(_shippingFeeController.text),
          tags: _tags,
          discountPrice: discountPrice,
          discountStartDate: _discountStartDate,
          discountEndDate: _discountEndDate,
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
          description: descriptionJson,
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
          discountPrice: discountPrice,
          discountStartDate: _discountStartDate,
        discountEndDate: _discountEndDate,
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
                      _findCategoryPath(
                          widget.productToEdit!.categoryId, allCategories);
                      setState(() {});
                    }
                  });
                }
                return _buildForm(allCategories);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Text('카테고리를 불러올 수 없습니다: $e'),
            ),
          ),
        ),
      ),
    );
  }

  // ⭐️ 3. 날짜 선택을 위한 헬퍼 함수 추가
Future<void> _selectDate(BuildContext context, bool isStartDate) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: (isStartDate ? _discountStartDate : _discountEndDate) ?? DateTime.now(),
    firstDate: DateTime(2020),
    lastDate: DateTime(2101),
  );
  if (picked != null) {
    setState(() {
      if (isStartDate) {
        _discountStartDate = picked;
      } else {
        _discountEndDate = picked;
      }
    });
  }
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
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8)),
            child: _selectedImageBytes != null
                ? Image.memory(_selectedImageBytes!, fit: BoxFit.cover)
                : (_existingImageUrl != null && _existingImageUrl!.isNotEmpty
                    ? Image.network(_existingImageUrl!, fit: BoxFit.cover)
                    : const Center(child: Text('이미지 없음'))),
          ),
          TextButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.upload_file),
            label: const Text('대표 이미지 선택'),
          ),
          const SizedBox(height: 16),
          TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '상품명'),
              validator: (v) => v!.isEmpty ? '필수 항목입니다.' : null),
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
                _level2Categories =
                    allCategories.firstWhere((c) => c.id == value).children;
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
                  _level3Categories =
                      _level2Categories.firstWhere((c) => c.id == value).children;
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
          TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: '가격'),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? '필수 항목입니다.' : null),
          const SizedBox(height: 16),
          Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '할인 정보 설정',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _discountPriceController,
                  decoration: const InputDecoration(
                    labelText: '할인 가격',
                    hintText: '미입력 시 할인 없음',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, true),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: '할인 시작일',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          ),
                          child: Text(
                            _discountStartDate != null
                                ? "${_discountStartDate!.toLocal()}".split(' ')[0]
                                : '날짜 선택',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, false),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: '할인 종료일',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          ),
                          child: Text(
                            _discountEndDate != null
                                ? "${_discountEndDate!.toLocal()}".split(' ')[0]
                                : '날짜 선택',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
  controller: _discountPriceController,
  decoration: const InputDecoration(labelText: '할인 가격 (미입력 시 할인 없음)'),
  keyboardType: TextInputType.number,
),
              ],
            ),
          ),
        
          
),
const SizedBox(height: 16),
          TextFormField(
            controller: _shippingFeeController,
            decoration: const InputDecoration(labelText: '배송비'),
            keyboardType: TextInputType.number,
            validator: (v) => v!.isEmpty ? '필수 항목입니다.' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
              controller: _stockController,
              decoration: const InputDecoration(labelText: '재고 (옵션이 없을 경우)'),
              keyboardType: TextInputType.number,
              validator: (v) =>
                  v!.isEmpty && _optionGroups.isEmpty ? '필수 항목입니다.' : null),
          
          const SizedBox(height: 24),
          Text('상세 설명', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
           QuillSimpleToolbar(
            controller: _quillController,
            config: QuillSimpleToolbarConfig(
              embedButtons: FlutterQuillEmbeds.toolbarButtons(
                imageButtonOptions: QuillToolbarImageButtonOptions(
                  // ⭐️ 1. imageButtonConfig를 사용하여 이미지 선택 로직을 정의합니다.
                  imageButtonConfig: QuillToolbarImageConfig(
                    // ⭐️ 2. 라이브러리가 이미지를 선택하면,
                    //    우리는 그 파일(file)을 받아 업로드하고 URL을 반환하는 역할만 수행합니다.
                    onImageInsertCallback: (image, controller) async {
                      final picker = ImagePicker();
                      final file = await picker.pickImage(source: ImageSource.gallery);
                      if (file == null) return;
                      
                      // ⭐️ 3. 수정한 _onImagePickCallback 함수를 호출합니다.
                    //    이제 file(XFile)을 인자로 정상적으로 전달합니다.
                    final imageUrl = await _onImagePickCallback(file);
                    
                    // ⭐️ 4. imageUrl이 null이 아닌지, 그리고 비어있지 않은지 함께 확인합니다.
                    if (imageUrl != null && imageUrl.isNotEmpty) {
                      // ⭐️ 5. null이 아님이 확인되었으므로, non-nullable String으로 안전하게 전달합니다.
                      // ignore: deprecated_member_use
                      controller.insertImageBlock(imageSource: imageUrl);
                      }
                    },
                  ),
                ),
              ),
              showAlignmentButtons: true,
            ),
          ),
          const Divider(height: 1),
          Container(
            height: 400,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: QuillEditor.basic(
              controller: _quillController,
              // ⭐️ 4. config에서 const를 제거하고 embedBuilders를 추가합니다.
              config: QuillEditorConfig(
                padding: const EdgeInsets.all(8),
                embedBuilders: FlutterQuillEmbeds.editorBuilders(),
              ),
            ),
          ),
          const SizedBox(height: 16),

          TextFormField(
              controller: _productCodeController,
              decoration: const InputDecoration(labelText: '상품 코드 (선택)')),
          const SizedBox(height: 16),
          TextFormField(
              controller: _relatedProductCodeController,
              decoration: const InputDecoration(labelText: '연관 상품 코드 (선택)')),
          const Divider(height: 48),
          Text('상품 태그 설정', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
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
          SwitchListTile(
              title: const Text('쇼핑몰에 진열'),
              value: _isDisplayed,
              onChanged: (v) => setState(() => _isDisplayed = v)),
          SwitchListTile(
              title: const Text('품절 처리 (옵션이 없을 경우)'),
              value: _isSoldOut,
              onChanged: (v) => setState(() => _isSoldOut = v)),
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
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }

  void _findCategoryPath(int? categoryId, List<CategoryModel> allCategories) {
    if (categoryId == null) return;
    for (var l1Cat in allCategories) {
      if (l1Cat.id == categoryId) {
        _level1CategoryId = l1Cat.id;
        _level2Categories = l1Cat.children;
        return;
      }
      for (var l2Cat in l1Cat.children) {
        if (l2Cat.id == categoryId) {
          _level1CategoryId = l1Cat.id;
          _level2Categories = l1Cat.children;
          _level2CategoryId = l2Cat.id;
          _level3Categories = l2Cat.children;
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
                          decoration:
                              const InputDecoration(labelText: '옵션 그룹명 (예: 색상)'),
                          onChanged: (value) => group.name = value,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline,
                            color: Colors.redAccent),
                        onPressed: () => _removeOptionGroup(index),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: group.values
                        .map((v) => Chip(
                              label: Text(v.value),
                              onDeleted: () =>
                                  setState(() => group.values.remove(v)),
                            ))
                        .toList(),
                  ),
                  TextFormField(
                    controller: _optionValueControllers[index],
                    focusNode: _optionValueFocusNodes[index],
                    decoration:
                        const InputDecoration(labelText: '옵션 값 추가 (입력 후 Enter)'),
                    onFieldSubmitted: (value) {
                      if (value.isNotEmpty) {
                        setState(() {
                          group.values.add(OptionValue(value: value));
                          _optionValueControllers[index].clear();
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
        if (_optionGroups.length < 3)
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
                decoration:
                    const InputDecoration(prefixText: '+', suffixText: '원'),
                onChanged: (v) =>
                    variant.additionalPrice = int.tryParse(v) ?? 0,
              )),
              DataCell(TextFormField(
                initialValue: variant.stockQuantity.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(suffixText: '개'),
                onChanged: (v) =>
                    variant.stockQuantity = int.tryParse(v) ?? 0,
              )),
            ]);
          }).toList(),
        )
      ],
    );
  }


}