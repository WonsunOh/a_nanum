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
import '../widgets/product_image_selector.dart';

class AddEditProductScreen extends ConsumerStatefulWidget {
  final ProductModel? productToEdit;

  const AddEditProductScreen({super.key, this.productToEdit});

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
  bool _stockAutoCalculated = false; // 자동 계산 여부 추적
  late TextEditingController _productCodeController;
  late TextEditingController _relatedProductCodeController;
  late TextEditingController _shippingFeeController;
  late TextEditingController _discountPriceController;
  // ⭐️ 1. 할인 기간을 저장할 변수 추가
  DateTime? _discountStartDate;
  DateTime? _discountEndDate;

  bool _disposed = false; // ✅ 추가

  Map<String, bool> _tags = {
    'is_hit': false,
    'is_recommended': false,
    'is_new': false,
    'is_popular': false,
    'is_discount': false,
  };

  //✅ 단일 이미지 변수들을 리스트로 변경
  final List<XFile> _selectedImageFiles = [];
  final List<Uint8List> _selectedImageBytes = [];
  final List<String> _existingImageUrls = [];

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

  void _safeSetState(VoidCallback fn) {
    if (!_disposed && mounted) {
      setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.productToEdit?.name ?? '',
    );
    _initializeQuillController();
    _priceController = TextEditingController(
      text: widget.productToEdit?.price.toString() ?? '',
    );
    _stockController = TextEditingController(
      text: widget.productToEdit?.stockQuantity.toString() ?? '',
    );
    _productCodeController = TextEditingController(
      text: widget.productToEdit?.productCode ?? '',
    );
    _relatedProductCodeController = TextEditingController(
      text: widget.productToEdit?.relatedProductCode ?? '',
    );
    _isDisplayed = widget.productToEdit?.isDisplayed ?? true;
    _isSoldOut = widget.productToEdit?.isSoldOut ?? false;
    _shippingFeeController = TextEditingController(
      text: widget.productToEdit?.shippingFee.toString() ?? '3000',
    );

    if (widget.productToEdit != null) {
      _tags = widget.productToEdit!.tags;
      _discountStartDate = widget.productToEdit?.discountStartDate;
      _discountEndDate = widget.productToEdit?.discountEndDate;
    }

    // ✅ 할인 가격 컨트롤러 한 번만 정의
    _discountPriceController = TextEditingController(
      text: widget.productToEdit?.discountPrice?.toString() ?? '',
    );

    if (_isEditMode) {
      // ✅ 수정 모드일 때 완전한 상품 정보를 다시 가져오기
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadCompleteProductData();
      });
    }
  }

  // ✅ 완전한 상품 데이터를 로드하는 메서드 추가
  Future<void> _loadCompleteProductData() async {
    if (!mounted || widget.productToEdit == null) return;

    try {
      final repository = ref.read(productRepositoryProvider);
      final results = await Future.wait([
        repository.fetchProductById(widget.productToEdit!.id),
        repository.fetchOptionsAndVariants(widget.productToEdit!.id),
      ]);

      final completeProduct = results[0] as ProductModel;
      final optionsData =
          results[1] as (List<OptionGroup>, List<ProductVariant>);

      if (mounted) {
        _safeSetState(() {
          _existingImageUrls.clear();

          if (completeProduct.imageUrl != null) {
            _existingImageUrls.add(completeProduct.imageUrl!);
          }
          if (completeProduct.additionalImages != null) {
            _existingImageUrls.addAll(completeProduct.additionalImages!);
          }

          _optionGroups = optionsData.$1;
          _variants = optionsData.$2;
          _initializeControllers();
        });
      }
    } catch (e) {
      debugPrint('상품 데이터 로드 실패: $e');
    }
  }

  // 변형 재고 변경 시 총 재고 자동 계산
  void _updateTotalStock() {
    if (_variants.isNotEmpty) {
      final totalStock = _variants.fold(
        0,
        (sum, variant) => sum + variant.stockQuantity,
      );
      setState(() {
        _stockController.text = totalStock.toString();
        _stockAutoCalculated = true;
      });
    }
  }

  // 옵션 조합 생성 시 재고도 함께 업데이트
  void _generateVariants() {
    if (_optionGroups.isEmpty) {
      setState(() {
        _variants = [];
        _stockAutoCalculated = false;
      });
      return;
    }

    List<List<String>> allValues = _optionGroups
        .map((group) => group.values.map((v) => v.value).toList())
        .where((list) => list.isNotEmpty)
        .toList();

    if (allValues.isEmpty) {
      setState(() {
        _variants = [];
        _stockAutoCalculated = false;
      });
      return;
    }

    List<String> combinations = allValues.fold<List<String>>([''], (
      previous,
      element,
    ) {
      return previous
          .expand((p) => element.map((e) => p.isEmpty ? e : '$p / $e'))
          .toList();
    });

    setState(() {
      _variants = combinations
          .map(
            (name) => ProductVariant(
              name: name,
              additionalPrice: 0,
              stockQuantity: 0, // 기본값 0으로 설정
            ),
          )
          .toList();
      _updateTotalStock(); // 총 재고 자동 계산
    });
  }

  void _initializeQuillController() {
    final description = widget.productToEdit?.description;

    try {
      if (description != null && description.isNotEmpty) {
        // JSON 형태인지 확인
        if (description.trimLeft().startsWith('[') ||
            description.trimLeft().startsWith('{')) {
          final doc = Document.fromJson(jsonDecode(description));
          _quillController = QuillController(
            document: doc,
            selection: const TextSelection.collapsed(offset: 0),
          );
        } else {
          // 일반 텍스트인 경우
          final doc = Document()..insert(0, description);
          _quillController = QuillController(
            document: doc,
            selection: const TextSelection.collapsed(offset: 0),
          );
        }
      } else {
        // 새 문서 생성
        _quillController = QuillController.basic();
      }
    } catch (e) {
      // 오류 발생 시 빈 문서로 초기화
      _quillController = QuillController.basic();
    }
  }

  void _initializeControllers() {
    _optionValueControllers = List.generate(
      _optionGroups.length,
      (_) => TextEditingController(),
    );
    _optionValueFocusNodes = List.generate(
      _optionGroups.length,
      (_) => FocusNode(),
    );
  }

  void _addOptionGroup() {
    _safeSetState(() {
      _optionGroups.add(OptionGroup(name: '', values: []));
      _optionValueControllers.add(TextEditingController());
      _optionValueFocusNodes.add(FocusNode());
    });
  }

  void _removeOptionGroup(int index) {
    _safeSetState(() {
      _optionGroups.removeAt(index);
      _optionValueControllers.removeAt(index).dispose();
      _optionValueFocusNodes.removeAt(index).dispose();
    });
  }

  // ✅ 이미지 순서를 수동으로 조정하는 메서드 (필요시 사용)
  void _reorderImages(int oldIndex, int newIndex) {
    _safeSetState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final String item = _existingImageUrls.removeAt(oldIndex);
      _existingImageUrls.insert(newIndex, item);
    });
  }

  @override
  void dispose() {
    _disposed = true; // ✅ dispose 상태 추적 변수 추가
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

  Future<void> _pickImages() async {
    final imagePicker = ImagePicker();
    final files = await imagePicker.pickMultiImage();

    if (files.isNotEmpty) {
      List<Uint8List> byteslist = [];
      for (var file in files) {
        final bytes = await file.readAsBytes();
        byteslist.add(bytes);
      }

      _safeSetState(() {
        _selectedImageFiles.addAll(files);
        _selectedImageBytes.addAll(byteslist);
      });
    }
  }

  // 단일 이미지 추가 메서드
  Future<void> _pickSingleImage() async {
    final imagePicker = ImagePicker();
    final file = await imagePicker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      final bytes = await file.readAsBytes();
      _safeSetState(() {
        _selectedImageFiles.add(file);
        _selectedImageBytes.add(bytes);
      });
    }
  }

  // 이미지 삭제 메서드
  void _removeImage(int index, bool isExisting) {
    _safeSetState(() {
      if (isExisting) {
        _existingImageUrls.removeAt(index);
      } else {
        _selectedImageFiles.removeAt(index);
        _selectedImageBytes.removeAt(index);
      }
    });
  }

  // _buildImageSelector 메서드를 간단하게 교체
  Widget _buildImageSelector() {
    return ProductImageSelector(
      existingImageUrls: _existingImageUrls,
      selectedImageBytes: _selectedImageBytes,
      onPickSingleImage: _pickSingleImage,
      onPickMultipleImages: _pickImages,
      onRemoveImage: _removeImage,
    );
  }

  // Quill 에디터의 이미지 업로드를 처리하는 콜백 함수
  Future<String?> _onImagePickCallback(XFile file) async {
    try {
      final imageBytes = await file.readAsBytes();
      final fileExtension = file.name.split('.').last.toLowerCase();
      final imageName =
          'quill_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      // 이미지 업로드 (재시도 로직 추가)
      String? uploadPath;
      int retryCount = 0;
      const maxRetries = 3;

      while (retryCount < maxRetries) {
        try {
          uploadPath = await Supabase.instance.client.storage
              .from('products')
              .uploadBinary(imageName, imageBytes);

          if (uploadPath.isNotEmpty) {
            break; // 성공하면 루프 종료
          }
        } catch (uploadError) {
          retryCount++;
          if (retryCount < maxRetries) {
            await Future.delayed(
              Duration(milliseconds: 500 * retryCount),
            ); // 점진적 지연
          }
        }
      }

      if (uploadPath == null || uploadPath.isEmpty) {
        throw Exception('$maxRetries번 시도 후에도 업로드 실패');
      }

      // Public URL 생성
      final imageUrl = Supabase.instance.client.storage
          .from('products')
          .getPublicUrl(imageName);

      return imageUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 업로드 실패: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return null;
    }
  }

  Widget _buildQuillEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '상세 설명',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // 툴바
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: QuillSimpleToolbar(
            controller: _quillController,
            config: QuillSimpleToolbarConfig(
              customButtons: [
                QuillToolbarCustomButtonOptions(
                  icon: Icon(Icons.image),
                  tooltip: '이미지 삽입',
                  onPressed: () async {
                    final picker = ImagePicker();
                    final file = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (file != null) {
                      final imageUrl = await _onImagePickCallback(file);
                      if (imageUrl != null) {
                        final index = _quillController.selection.baseOffset;
                        _quillController.document.insert(
                          index,
                          BlockEmbed.image(imageUrl),
                        );
                        _quillController.updateSelection(
                          TextSelection.collapsed(offset: index + 1),
                          ChangeSource.local,
                        );
                      }
                    }
                  },
                ),
              ],
              multiRowsDisplay: true,
              buttonOptions: const QuillSimpleToolbarButtonOptions(
                base: QuillToolbarBaseButtonOptions(
                  iconSize: 14, // 아이콘 크기
                ),
              ),
              showAlignmentButtons: true,
              showBackgroundColorButton: false,
              showClearFormat: true,
              showColorButton: true,
              showCodeBlock: true,
              showInlineCode: false,
              showListCheck: true,
              showSubscript: true,
              showSuperscript: true,
              showSearchButton: false,
              embedButtons: [],
            ),
          ),
        ),

        // 에디터
        Container(
          height: 400,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          child: QuillEditor.basic(
            controller: _quillController,
            config: QuillEditorConfig(
              padding: const EdgeInsets.all(16),
              placeholder: '상품의 상세 설명을 입력하세요...',
              autoFocus: false,
              expands: false,
              scrollable: true,
              embedBuilders: FlutterQuillEmbeds.editorBuilders(),
            ),
          ),
        ),

        // 도움말 텍스트
        const SizedBox(height: 8),
        Text(
          '• 텍스트 서식, 이미지 삽입, 링크 추가 등이 가능합니다.\n• 이미지는 자동으로 업로드되어 저장됩니다.',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  int? get _finalCategoryId {
    return _level3CategoryId ?? _level2CategoryId ?? _level1CategoryId;
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_finalCategoryId == null) return;

    final price = int.tryParse(_priceController.text) ?? 0;
    final stockQuantity = int.tryParse(_stockController.text) ?? 0;
    final shippingFee = int.tryParse(_shippingFeeController.text) ?? 3000;
    final discountPrice = _discountPriceController.text.isNotEmpty
        ? int.tryParse(_discountPriceController.text)
        : null;

    if (price <= 0) return;

    String descriptionJson;
    try {
      final delta = _quillController.document.toDelta();
      descriptionJson = jsonEncode(delta.toJson());
    } catch (e) {
      descriptionJson = jsonEncode([
        {"insert": "\n"},
      ]);
    }

    try {
      final viewModel = ref.read(productViewModelProvider.notifier);

      if (_isEditMode) {
        final updatedProduct = widget.productToEdit!.copyWith(
          name: _nameController.text,
          description: descriptionJson,
          price: price,
          stockQuantity: stockQuantity,
          categoryId: _finalCategoryId,
          isDisplayed: _isDisplayed,
          isSoldOut: _isSoldOut,
          productCode: _productCodeController.text.trim(),
          relatedProductCode: _relatedProductCodeController.text.trim(),
          shippingFee: shippingFee,
          tags: _tags,
          discountPrice: discountPrice,
          discountStartDate: _discountStartDate,
          discountEndDate: _discountEndDate,
        );

        await viewModel.updateProductWithOptions(
          updatedProduct,
          optionGroups: _optionGroups,
          variants: _variants,
          imageFiles: _selectedImageFiles.isNotEmpty
              ? _selectedImageFiles
              : null,
          existingImageUrls: _existingImageUrls.isNotEmpty
              ? _existingImageUrls
              : null,
        );
      } else {
        await viewModel.addProduct(
          name: _nameController.text,
          description: descriptionJson,
          price: price,
          stockQuantity: stockQuantity,
          categoryId: _finalCategoryId!,
          isDisplayed: _isDisplayed,
          isSoldOut: _isSoldOut,
          imageFiles: _selectedImageFiles.isNotEmpty
              ? _selectedImageFiles
              : null,
          productCode: _productCodeController.text.trim(),
          relatedProductCode: _relatedProductCodeController.text.trim(),
          optionGroups: _optionGroups,
          variants: _variants,
          shippingFee: shippingFee,
          tags: _tags,
          discountPrice: discountPrice,
          discountStartDate: _discountStartDate,
          discountEndDate: _discountEndDate,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('상품이 성공적으로 저장되었습니다.')));
        context.go('/shop/products');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('저장 실패: $e')));
      }
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
                        widget.productToEdit!.categoryId,
                        allCategories,
                      );
                      _safeSetState(() {});
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
      initialDate:
          (isStartDate ? _discountStartDate : _discountEndDate) ??
          DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      _safeSetState(() {
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
          _buildImageSelector(),
          const SizedBox(height: 24),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: '상품명'),
            validator: (v) => v!.isEmpty ? '필수 항목입니다.' : null,
          ),
          const SizedBox(height: 16),
          _buildCategoryDropdown(
            hint: '1차 카테고리',
            value: _level1CategoryId,
            items: allCategories,
            onChanged: (value) {
              _safeSetState(() {
                _level1CategoryId = value;
                _level2CategoryId = null;
                _level3CategoryId = null;
                _level2Categories = allCategories
                    .firstWhere((c) => c.id == value)
                    .children;
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
                _safeSetState(() {
                  _level2CategoryId = value;
                  _level3CategoryId = null;
                  _level3Categories = _level2Categories
                      .firstWhere((c) => c.id == value)
                      .children;
                });
              },
            ),
          if (_level2CategoryId != null && _level3Categories.isNotEmpty)
            _buildCategoryDropdown(
              hint: '3차 카테고리',
              value: _level3CategoryId,
              items: _level3Categories,
              onChanged: (value) {
                _safeSetState(() {
                  _level3CategoryId = value;
                });
              },
            ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _priceController,
            decoration: const InputDecoration(labelText: '가격'),
            keyboardType: TextInputType.number,
            validator: (v) {
              if (v == null || v.isEmpty) return '필수 항목입니다.';
              final price = int.tryParse(v);
              if (price == null || price <= 0) return '올바른 가격을 입력하세요.';
              return null;
            },
          ),
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final discountPrice = int.tryParse(value);
                        if (discountPrice == null) {
                          return '올바른 숫자를 입력하세요';
                        }
                        final price = int.tryParse(_priceController.text) ?? 0;
                        if (discountPrice >= price) {
                          return '할인 가격은 원가보다 낮아야 합니다';
                        }
                      }
                      return null;
                    },
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
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                            ),
                            child: Text(
                              _discountStartDate != null
                                  ? "${_discountStartDate!.toLocal()}".split(
                                      ' ',
                                    )[0]
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
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                            ),
                            child: Text(
                              _discountEndDate != null
                                  ? "${_discountEndDate!.toLocal()}".split(
                                      ' ',
                                    )[0]
                                  : '날짜 선택',
                            ),
                          ),
                        ),
                      ),
                    ],
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
            validator: (v) {
              if (v == null || v.isEmpty) return '필수 항목입니다.';
              final fee = int.tryParse(v);
              if (fee == null || fee < 0) return '올바른 배송비를 입력하세요.';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildStockField(), // 개선된 재고 필드

          const SizedBox(height: 24),
          Text('상세 설명', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const SizedBox(height: 24),
          _buildQuillEditor(),
          const SizedBox(height: 24),

          TextFormField(
            controller: _productCodeController,
            decoration: const InputDecoration(labelText: '상품 코드 (선택)'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _relatedProductCodeController,
            decoration: const InputDecoration(labelText: '연관 상품 코드 (선택)'),
          ),
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
                      _safeSetState(() {
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
            onChanged: (v) => _safeSetState(() => _isDisplayed = v),
          ),
          SwitchListTile(
            title: const Text('품절 처리 (옵션이 없을 경우)'),
            value: _isSoldOut,
            onChanged: (v) => _safeSetState(() => _isSoldOut = v),
          ),
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
        initialValue: value,
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
                          decoration: const InputDecoration(
                            labelText: '옵션 그룹명 (예: 색상)',
                          ),
                          onChanged: (value) => group.name = value,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.redAccent,
                        ),
                        onPressed: () => _removeOptionGroup(index),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: group.values
                        .map(
                          (v) => Chip(
                            label: Text(v.value),
                            onDeleted: () =>
                                _safeSetState(() => group.values.remove(v)),
                          ),
                        )
                        .toList(),
                  ),
                  TextFormField(
                    controller: _optionValueControllers[index],
                    focusNode: _optionValueFocusNodes[index],
                    decoration: const InputDecoration(
                      labelText: '옵션 값 추가 (입력 후 Enter)',
                    ),
                    onFieldSubmitted: (value) {
                      if (value.isNotEmpty) {
                        _safeSetState(() {
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
          ),
      ],
    );
  }

  // 개선된 변형 에디터 UI
  Widget _buildVariantEditorUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('옵션 조합 관리', style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            if (_variants.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.inventory,
                      size: 16,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '총 재고: ${_variants.fold(0, (sum, v) => sum + v.stockQuantity)}개',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        if (_variants.isNotEmpty) ...[
          // 일괄 설정 도구
          Card(
            color: Colors.grey.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '일괄 설정',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: '추가 금액',
                            suffixText: '원',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onFieldSubmitted: (value) {
                            final price = int.tryParse(value) ?? 0;
                            setState(() {
                              for (var variant in _variants) {
                                variant.additionalPrice = price;
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: '재고 수량',
                            suffixText: '개',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onFieldSubmitted: (value) {
                            final stock = int.tryParse(value) ?? 0;
                            setState(() {
                              for (var variant in _variants) {
                                variant.stockQuantity = stock;
                              }
                              _updateTotalStock();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 개별 변형 테이블
          DataTable(
            columnSpacing: 20,
            headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
            columns: const [
              DataColumn(label: Text('옵션명')),
              DataColumn(label: Text('추가금액')),
              DataColumn(label: Text('재고')),
              DataColumn(label: Text('상태')),
            ],
            rows: _variants.asMap().entries.map((entry) {
              final variant = entry.value;

              return DataRow(
                cells: [
                  DataCell(
                    SizedBox(
                      width: 120,
                      child: Text(
                        variant.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 100,
                      child: TextFormField(
                        initialValue: variant.additionalPrice.toString(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          prefixText: '+',
                          suffixText: '원',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        ),
                        style: const TextStyle(fontSize: 12),
                        onChanged: (value) {
                          variant.additionalPrice = int.tryParse(value) ?? 0;
                        },
                      ),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 80,
                      child: TextFormField(
                        initialValue: variant.stockQuantity.toString(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          suffixText: '개',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        ),
                        style: const TextStyle(fontSize: 12),
                        onChanged: (value) {
                          variant.stockQuantity = int.tryParse(value) ?? 0;
                          _updateTotalStock(); // 재고 변경 시 총 재고 업데이트
                        },
                      ),
                    ),
                  ),
                  DataCell(_buildVariantStockStatus(variant.stockQuantity)),
                ],
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildVariantStockStatus(int stock) {
    if (stock <= 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        ),
        child: const Text(
          '품절',
          style: TextStyle(
            color: Colors.red,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (stock <= 5) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
        ),
        child: const Text(
          '부족',
          style: TextStyle(
            color: Colors.orange,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
        ),
        child: const Text(
          '충분',
          style: TextStyle(
            color: Colors.green,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  // 개선된 재고 입력 필드
  Widget _buildStockField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _stockController,
                decoration: InputDecoration(
                  labelText: '재고 (옵션이 없을 경우)',
                  suffixText: '개',
                  border: const OutlineInputBorder(),
                  helperText: _stockAutoCalculated
                      ? '옵션별 재고의 합계로 자동 계산됨'
                      : '옵션이 없을 때만 직접 입력',
                ),
                keyboardType: TextInputType.number,
                readOnly: _stockAutoCalculated,
                validator: (v) {
                  if (!_stockAutoCalculated && _optionGroups.isEmpty) {
                    return v!.isEmpty ? '필수 항목입니다.' : null;
                  }
                  return null;
                },
              ),
            ),
            if (_stockAutoCalculated)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Tooltip(
                  message: '옵션별 재고 합계',
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      color: Colors.green.shade700,
                      size: 20,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
