// user_app/lib/features/shop/view/product_detail_screen.dart (전체 교체)

import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/product_model.dart';
import '../../../data/models/product_variant_model.dart';
import '../../cart/viewmodel/cart_viewmodel.dart';
import '../../wishlist/viewmodel/wishlist_viewmodel.dart';
import '../viewmodel/product_detail_viewmodel.dart';


// 바로구매 데이터를 위한 전역 상태
class DirectPurchaseData {
  final int productId;
  final String productName;
  final int productPrice;
  final int? productDiscountPrice;
  final String? productImage;
  final List<Map<String, dynamic>> items;

  DirectPurchaseData({
    required this.productId,
    required this.productName,
    required this.productPrice,
    this.productDiscountPrice,
    this.productImage,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'productPrice': productPrice,
      'productDiscountPrice': productDiscountPrice,
      'productImage': productImage,
      'items': items,
    };
  }
}

// 바로구매 데이터 Provider
final directPurchaseProvider = StateProvider<DirectPurchaseData?>((ref) => null);


// 선택된 상품 항목 클래스
class SelectedVariantItem {
  final ProductVariant variant;
  int quantity;
  
  SelectedVariantItem({
    required this.variant,
    this.quantity = 1,
  });


  // ✅ 디버그용 toString 추가
  @override
  String toString() {
    return 'SelectedVariantItem(variant: ${variant.id}-${variant.name}, quantity: $quantity)';
  }
}

// 전역 선택된 상품 상태 관리
class SelectedItemsNotifier extends StateNotifier<List<SelectedVariantItem>> {
  SelectedItemsNotifier() : super([]);

   @override
  void dispose() {
    // ✅ 상태 초기화
    state = [];
    super.dispose();
  }

  void addItem(SelectedVariantItem item) {
    final existingIndex = state.indexWhere((i) => i.variant.id == item.variant.id);
    
    if (existingIndex >= 0) {
      final updatedList = [...state];
      updatedList[existingIndex].quantity += item.quantity;
      state = updatedList;
    } else {
      state = [...state, item];
    }
  }

  void updateQuantity(int index, int quantity) {
    if (index < 0 || index >= state.length) return;
    
    final updatedList = [...state];
    if (quantity <= 0) {
      updatedList.removeAt(index);
    } else {
      updatedList[index].quantity = quantity;
    }
    state = updatedList;
  }

  void removeItem(int index) {
    if (index < 0 || index >= state.length) return;
    final updatedList = [...state];
    updatedList.removeAt(index);
    state = updatedList;
  }

  void clear() {
    state = [];
  }
}

// 전역 상태 Provider
final selectedItemsProvider = StateNotifierProvider<SelectedItemsNotifier, List<SelectedVariantItem>>((ref) {
  return SelectedItemsNotifier();
});

class ProductDetailScreen extends ConsumerStatefulWidget {
  final int productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  Map<String, String> _currentOptions = {};
  late QuillController _descriptionController;

  bool _disposed = false; // ✅ dispose 상태 추적
  int _selectedTabIndex = 0;
  int _selectedImageIndex = 0; // ✅ 선택된 이미지 인덱스 추가
  ProductVariant? _selectedVariant;
  

  @override
  void initState() {
    super.initState();
    _descriptionController = QuillController.basic();
  }

  @override
  void dispose() {
    _disposed = true; // ✅ dispose 상태 설정
    _descriptionController.dispose();
    super.dispose();
  }

  // ✅ 모든 setState 호출을 안전하게 감싸는 메서드
  void _safeSetState(VoidCallback fn) {
    if (!_disposed && mounted) {
      setState(fn);
    }
  }

  // ✅ 이미지 선택 메서드 추가
  void _selectImage(int index) {
    _safeSetState(() {
      _selectedImageIndex = index;
    });
  }

  // ✅ 모든 setState 호출을 _safeSetState로 변경
  void _onOptionSelected(String groupName, String selectedValue, List<ProductVariant> variants) {
    _safeSetState(() {
      _currentOptions = Map<String, String>.from(_currentOptions);
      _currentOptions[groupName] = selectedValue;
    });

    final productDetailAsync = ref.read(productDetailProvider(widget.productId));
    productDetailAsync.whenData((productDetailState) {
      final optionGroups = productDetailState.optionGroups;
      
      if (_currentOptions.length == optionGroups.length) {
        final selectedCombinationName = optionGroups
            .map((group) => _currentOptions[group.name])
            .join(' / ');

        final foundVariant = variants.firstWhereOrNull(
          (v) => v.name == selectedCombinationName,
        );

        if (foundVariant != null) {
          _addVariantToList(foundVariant);
          
          _safeSetState(() { // ✅ 여기도 _safeSetState 사용
            _currentOptions = {};
          });
          
          // ✅ SnackBar도 안전하게 표시
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('"${foundVariant.name}" 선택 완료'),
                duration: const Duration(seconds: 1),
              ),
            );
          }
        }
      }
    });
  }

  void _toggleFavorite() async {
  try {
    print('찜하기 버튼 클릭: 상품 ${widget.productId}');
    
    final resultMessage = await ref.read(wishlistToggleProvider.notifier).toggleWishlist(widget.productId);
    
    if (mounted) {
      final isAddAction = resultMessage.contains('추가');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isAddAction ? Icons.favorite : Icons.heart_broken,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(resultMessage),
            ],
          ),
          duration: const Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.fixed, // ✅ floating에서 fixed로 변경
          // margin 제거하여 화면 제일 아래에 표시
          backgroundColor: isAddAction ? Colors.green[600] : Colors.orange[600],
        ),
      );
    }
  } catch (e) {
    print('찜하기 에러: $e');
    if (mounted) {
       // 로그인 관련 에러 메시지 개선
      String errorMessage;
      if (e.toString().contains('로그인이 필요합니다') || 
          e.toString().contains('로그인') ||
          e.toString().contains('Exception: 로그인')) {
        errorMessage = '찜하기 기능을 사용하려면 로그인해주세요';
      } else {
        errorMessage = '일시적인 오류가 발생했습니다. 다시 시도해주세요';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(errorMessage)),
            ],
          ),
          duration: const Duration(milliseconds: 2000),
          behavior: SnackBarBehavior.fixed, // ✅ 에러 메시지도 하단 고정
          backgroundColor: Colors.blue[600], // 로그인 안내는 파란색
          action: e.toString().contains('로그인') 
              ? SnackBarAction(
                  label: '로그인',
                  textColor: Colors.white,
                  onPressed: () {
                    context.go('/login');
                  },
                )
              : null,
        ),
      );
    }
  }
}

  // 설명을 Quill 컨트롤러에 설정하는 메서드
  void _setDescription(String? description) {
    if (_disposed) return; // ✅ 일찍 반환
    if (description == null || description.isEmpty) {
      _descriptionController.document = Document()..insert(0, '상세 설명이 없습니다.');
      return;
    }

    if (description.trimLeft().startsWith('[')) {
      try {
        _descriptionController.document = Document.fromJson(jsonDecode(description));
      } catch (e) {
        _descriptionController.document = Document()..insert(0, '상세 설명을 불러올 수 없습니다.');
      }
    } else {
      _descriptionController.document = Document()..insert(0, description);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 장바구니 에러 리스닝
    ref.listen<AsyncValue>(cartViewModelProvider, (previous, next) {
    // 이전 상태와 비교하여 새로운 에러만 처리
    if (next.hasError && 
        !next.isLoading && 
        previous != next &&
        previous?.hasError != true) {
      _handleCartError(next.error!);
    }
  });

    final productDetailAsync = ref.watch(productDetailProvider(widget.productId));

    final isWishlistedAsync = ref.watch(isProductWishlistedProvider(widget.productId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('상품 정보'),
        actions: [
          Consumer(
    builder: (context, ref, child) {
      final isWishlistedAsync = ref.watch(isProductWishlistedProvider(widget.productId));
      
      return isWishlistedAsync.when(
        data: (isWishlisted) => IconButton(
          onPressed: _toggleFavorite,
          icon: Icon(
            isWishlisted ? Icons.favorite : Icons.favorite_border,
            color: isWishlisted ? Colors.red : null,
          ),
          tooltip: isWishlisted ? '찜 해제' : '찜하기',
        ),
        loading: () => IconButton(
          onPressed: null,
          icon: const Icon(Icons.favorite_border),
          tooltip: '로딩 중...',
        ),
        error: (_, __) => IconButton(
          onPressed: _toggleFavorite,
          icon: const Icon(Icons.favorite_border),
          tooltip: '찜하기',
        ),
      );
    },
  ),
        ],
      ),
      body: productDetailAsync.when(
        data: (productDetailState) {
          // 설명 설정
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _setDescription(productDetailState.product.description);
            }
          });
          
          return LayoutBuilder(
            builder: (context, constraints) {
              bool isWideScreen = constraints.maxWidth > 768;
              return SingleChildScrollView(
                child: isWideScreen
                    ? _buildWideLayout(context, productDetailState)
                    : _buildNarrowLayout(context, productDetailState),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Text('상품 정보를 불러오는 데 실패했습니다: $e'),
        ),
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 768) {
            return const SizedBox.shrink();
          }
          return productDetailAsync.when(
            data: (productDetailState) => _buildBottomBar(context, productDetailState),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          );
        },
      ),
    );
  }

  Widget _buildNarrowLayout(BuildContext context, ProductDetailState productDetailState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildProductImage(productDetailState.product),
        _buildProductInfo(context, productDetailState),
      ],
    );
  }

  Widget _buildWideLayout(BuildContext context, ProductDetailState productDetailState) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildProductImage(productDetailState.product),
              ),
              const SizedBox(width: 48),
              Expanded(
                flex: 3,
                child: _buildProductInfo(
                  context,
                  productDetailState,
                  showDescription: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildProductDetailTabs(productDetailState.product),
        ],
      ),
    );
  }

  // ✅ 개선된 이미지 표시 위젯 (화살표 네비게이션 추가)
  Widget _buildProductImage(ProductModel product) {
    // 모든 이미지 리스트 생성 (대표 이미지 + 추가 이미지들)
    final List<String> allImages = [];
    
    // 대표 이미지 추가
    if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
      allImages.add(product.imageUrl!);
    }
    
    // 추가 이미지들 추가
    if (product.additionalImages != null) {
      for (final additionalImage in product.additionalImages!) {
        if (additionalImage.isNotEmpty) {
          allImages.add(additionalImage);
        }
      }
    }

    // 이미지가 없는 경우
    if (allImages.isEmpty) {
      return Container(
        height: 400,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
              SizedBox(height: 8),
              Text('이미지가 없습니다', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    // 선택된 인덱스가 범위를 벗어나지 않도록 보정
    if (_selectedImageIndex >= allImages.length) {
      _selectedImageIndex = 0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ 메인 이미지와 화살표 네비게이션
        Stack(
          children: [
            GestureDetector(
              onTap: () => _showImagePreview(allImages, _selectedImageIndex),
              child: Container(
                height: MediaQuery.of(context).size.width > 768 ? 400 : 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    allImages[_selectedImageIndex],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey.shade100,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                            color: Colors.teal,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image, size: 60, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('이미지를 불러올 수 없습니다', 
                                 style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // ✅ 왼쪽 화살표 (이미지가 2개 이상일 때만)
            if (allImages.length > 1)
              Positioned(
                left: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      _safeSetState(() {
                        _selectedImageIndex = _selectedImageIndex > 0 
                            ? _selectedImageIndex - 1 
                            : allImages.length - 1;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            
            // ✅ 오른쪽 화살표
            if (allImages.length > 1)
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      _safeSetState(() {
                        _selectedImageIndex = _selectedImageIndex < allImages.length - 1 
                            ? _selectedImageIndex + 1 
                            : 0;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            
            // ✅ 이미지 인디케이터 점들
            if (allImages.length > 1)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    allImages.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == _selectedImageIndex
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        
        // ✅ 이미지가 2개 이상일 때만 썸네일 갤러리 표시
        if (allImages.length > 1) ...[
          const SizedBox(height: 16),
          
          // 이미지 개수 표시
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.photo_library, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '${_selectedImageIndex + 1} / ${allImages.length}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // 썸네일 리스트
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemCount: allImages.length,
              itemBuilder: (context, index) {
                final isSelected = index == _selectedImageIndex;
                
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < allImages.length - 1 ? 12 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () => _selectImage(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? Colors.teal : Colors.grey.shade300,
                          width: isSelected ? 3 : 1,
                        ),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: Colors.teal.withOpacity(0.3),
                            spreadRadius: 0,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ] : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Stack(
                          children: [
                            Image.network(
                              allImages[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.broken_image, 
                                                size: 24, color: Colors.grey),
                              ),
                            ),
                            if (isSelected)
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: Colors.teal.withOpacity(0.2),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  // ✅ 이미지 확대 보기 다이얼로그 추가
  void _showImagePreview(List<String> images, int initialIndex) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: PageView.builder(
                controller: PageController(initialPage: initialIndex),
                itemCount: images.length,
                onPageChanged: (index) {
                  _safeSetState(() {
                    _selectedImageIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return InteractiveViewer(
                    maxScale: 3.0,
                    child: Image.network(
                      images[index],
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image, 
                                 size: 80, color: Colors.white54),
                            SizedBox(height: 16),
                            Text('이미지를 불러올 수 없습니다',
                                 style: TextStyle(color: Colors.white54)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // 닫기 버튼
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                  shape: const CircleBorder(),
                ),
              ),
            ),
            // 이미지 인덱스 표시
            if (images.length > 1)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 32,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_selectedImageIndex + 1} / ${images.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

// 탭 인덱스 상태 관리를 위한 변수 추가 (클래스 상단에)
Widget _buildProductDetailTabs(ProductModel product) {
  final tabs = [
    {'title': '상품정보', 'count': null},
    {'title': '사용후기', 'count': 0},
    {'title': '상품문의', 'count': 0},
    {'title': '배송정보', 'count': null},
    {'title': '교환정보', 'count': null},
  ];

  return Container(
    margin: const EdgeInsets.only(top: 32),
    child: Column(
      children: [
        // 탭 헤더
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Row(
            children: [
              for (int i = 0; i < tabs.length; i++)
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTabIndex = i;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _selectedTabIndex == i 
                          ? Colors.white 
                          : Colors.grey.shade50,
                        border: Border(
                          right: i < tabs.length - 1 
                            ? BorderSide(color: Colors.grey.shade300) 
                            : BorderSide.none,
                          bottom: _selectedTabIndex == i
                            ? const BorderSide(color: Colors.teal, width: 3)
                            : BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            tabs[i]['title'] as String,
                            style: TextStyle(
                              fontWeight: _selectedTabIndex == i 
                                ? FontWeight.bold 
                                : FontWeight.normal,
                              color: _selectedTabIndex == i
                                ? Colors.black
                                : Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          if (tabs[i]['count'] != null) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6, 
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${tabs[i]['count']}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // 탭 내용
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          child: _buildTabContent(_selectedTabIndex, product),
        ),
      ],
    ),
  );
}

// 각 탭의 내용을 빌드하는 위젯
Widget _buildTabContent(int tabIndex, ProductModel product) {
  switch (tabIndex) {
    case 0: // 상품정보
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: _buildDescriptionWidget(),
      );
    case 1: // 사용후기
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.rate_review_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              '아직 작성된 사용후기가 없습니다.',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '첫 번째 후기를 작성해보세요!',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    case 2: // 상품문의
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.help_outline, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              '상품에 대해 궁금한 점이 있으신가요?',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // 문의하기 기능 구현
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('문의하기 기능은 준비 중입니다.')),
                );
              },
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('상품 문의하기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    case 3: // 배송정보
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoSection('배송방법', '택배'),
            _buildInfoSection('배송비', '${NumberFormat.currency(locale: 'ko_KR', symbol: '₩').format(product.shippingFee)}'),
            _buildInfoSection('배송지역', '전국 (도서산간 지역 제외)'),
            _buildInfoSection('배송기간', '주문 후 1-3일 (주말/공휴일 제외)'),
            _buildInfoSection('무료배송 조건', '50,000원 이상 구매시'),
            const Divider(height: 32),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '도서산간 지역은 추가 배송비가 발생할 수 있습니다.',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    case 4: // 교환정보
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoSection('교환/반품 기간', '상품 수령 후 7일 이내'),
            _buildInfoSection('교환/반품 비용', '고객 변심: 왕복배송비 고객부담\n상품하자: 무료'),
            _buildInfoSection('교환/반품 불가 사유', '• 사용 또는 일부 소비된 상품\n• 시간이 지나 재판매가 곤란한 상품\n• 복제가 가능한 상품'),
            const Divider(height: 32),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_outlined, color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '교환/반품을 원하시는 경우 고객센터로 먼저 연락주세요.',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    default:
      return const SizedBox.shrink();
  }
}

// 정보 섹션을 빌드하는 헬퍼 위젯
Widget _buildInfoSection(String title, String content) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            content,
            style: TextStyle(
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
}

  // 설명 표시 위젯
  Widget _buildDescriptionWidget() {
    return QuillEditor.basic(
      controller: _descriptionController,
      config: QuillEditorConfig(
        autoFocus: false,
        expands: false,
        padding: EdgeInsets.zero,
        scrollable: false,
        embedBuilders: FlutterQuillEmbeds.editorBuilders(),
      ),
    );
  }

  Widget _buildProductInfo(
    BuildContext context,
    ProductDetailState productDetailState, {
    bool showDescription = true,
  }) {
    final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');
    final product = productDetailState.product;
    final hasDiscount = product.discountPrice != null && product.discountPrice! < product.price;
    final basePrice = hasDiscount ? product.discountPrice! : product.price;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          
          // 가격 표시
          if (hasDiscount)
            Text(
              currencyFormat.format(product.price),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                decoration: TextDecoration.lineThrough,
                color: Colors.grey,
              ),
            ),
          Text(
            currencyFormat.format(basePrice),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const Divider(height: 48),
          _buildInfoRow('배송비', currencyFormat.format(product.shippingFee)),
          const SizedBox(height: 24),

          // 상품선택 섹션
          _buildProductSelectionSection(productDetailState),
          
          // 선택된 상품 목록
          _buildSelectedItemsList(product),
          
          // 총 금액
          _buildTotalSection(product),

          const SizedBox(height: 24),
          
          // 하단 버튼 섹션 (넓은 화면에서만)
          if (MediaQuery.of(context).size.width > 768)
            _buildPurchaseButtons(context, product),
          // ✅ 기존 상품 설명 부분을 이것으로 교체
        if (showDescription) 
          _buildProductDetailTabs(product),
      
        ],
      ),
    );
  }

  // 상품선택 드롭다운 섹션
  Widget _buildProductSelectionSection(ProductDetailState productDetailState) {
    final optionGroups = productDetailState.optionGroups;
    if (optionGroups.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상품선택 헤더
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: const Text(
              '상품선택',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          
          // 드롭다운들
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                for (int i = 0; i < optionGroups.length; i++)
                  Padding(
                    padding: EdgeInsets.only(bottom: i < optionGroups.length - 1 ? 12 : 0),
                    child: _buildOptionDropdown(optionGroups[i], productDetailState.variants),
                  ),
                
                // 현재 선택 진행 상태 표시
                if (_currentOptions.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildCurrentSelectionStatus(optionGroups),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 현재 선택 진행 상태를 보여주는 위젯
  Widget _buildCurrentSelectionStatus(List optionGroups) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade600, size: 16),
              const SizedBox(width: 8),
              Text(
                '선택 중인 옵션',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...optionGroups.map((group) {
            final selectedValue = _currentOptions[group.name];
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Text(
                    '${group.name}: ',
                    style: const TextStyle(fontSize: 13),
                  ),
                  Text(
                    selectedValue ?? '선택하세요',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: selectedValue != null ? Colors.black : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (selectedValue != null)
                    const Icon(Icons.check_circle, color: Colors.green, size: 16)
                  else
                    const Icon(Icons.radio_button_unchecked, color: Colors.grey, size: 16),
                ],
              ),
            );
          }),
          
          // 완료 상태 표시
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _currentOptions.length / optionGroups.length,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            '${_currentOptions.length}/${optionGroups.length} 선택 완료',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // 개별 옵션 드롭다운
  Widget _buildOptionDropdown(dynamic optionGroup, List<ProductVariant> variants) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          optionGroup.name,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('${optionGroup.name}을(를) 선택해주세요'),
              ),
              value: _currentOptions[optionGroup.name],
              onChanged: (String? newValue) {
                if (newValue != null) {
                  _onOptionSelected(optionGroup.name, newValue, variants);
                }
              },
              items: optionGroup.values.map<DropdownMenuItem<String>>((value) {
                return DropdownMenuItem<String>(
                  value: value.value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(value.value),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  

  // Variant를 전역 상태에 추가
  void _addVariantToList(ProductVariant variant) {
    ref.read(selectedItemsProvider.notifier).addItem(
      SelectedVariantItem(variant: variant),
    );
  }

  // 선택된 상품 목록 표시
  Widget _buildSelectedItemsList(ProductModel product) {
    final selectedItems = ref.watch(selectedItemsProvider);
    if (selectedItems.isEmpty) return const SizedBox.shrink();

    final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '');

    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          for (int i = 0; i < selectedItems.length; i++)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: i < selectedItems.length - 1
                    ? Border(bottom: BorderSide(color: Colors.grey.shade200))
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedItems[i].variant.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  // 수량 조절 버튼
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () => _updateItemQuantity(i, selectedItems[i].quantity - 1),
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(Icons.remove, size: 16),
                          ),
                        ),
                        Container(
                          width: 40,
                          alignment: Alignment.center,
                          child: Text('${selectedItems[i].quantity}'),
                        ),
                        InkWell(
                          onTap: () => _updateItemQuantity(i, selectedItems[i].quantity + 1),
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(Icons.add, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '+${currencyFormat.format(selectedItems[i].variant.additionalPrice)}원',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => _removeItem(i),
                    icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // 총 금액 섹션
  Widget _buildTotalSection(ProductModel product) {
    final selectedItems = ref.watch(selectedItemsProvider);
    if (selectedItems.isEmpty) return const SizedBox.shrink();

    final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '');
    final hasDiscount = product.discountPrice != null && product.discountPrice! < product.price;
    final basePrice = hasDiscount ? product.discountPrice! : product.price;

    int totalAmount = 0;
    for (final item in selectedItems) {
      final itemPrice = basePrice + item.variant.additionalPrice;
      totalAmount += itemPrice * item.quantity;
    }

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('총 금액', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(
            '${currencyFormat.format(totalAmount)}원',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
          ),
        ],
      ),
    );
  }

  // 하단 구매 버튼들
Widget _buildPurchaseButtons(BuildContext context, ProductModel product) {
  final selectedItems = ref.watch(selectedItemsProvider);
  final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');
  
  // 선택된 아이템들의 총 금액 계산
  int totalAmount = 0;
  int totalQuantity = 0;
  
  if (selectedItems.isNotEmpty) {
    final hasDiscount = product.discountPrice != null && product.discountPrice! < product.price;
    final basePrice = hasDiscount ? product.discountPrice! : product.price;
    
    for (final item in selectedItems) {
      final itemPrice = basePrice + item.variant.additionalPrice;
      totalAmount += itemPrice * item.quantity;
      totalQuantity += item.quantity;
    }
  }

  return Column(
    children: [
      // 총 금액 표시 (선택된 아이템이 있을 때만)
      if (selectedItems.isNotEmpty)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('총 ${totalQuantity}개 선택', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              Text(
                currencyFormat.format(totalAmount),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
            ],
          ),
        ),
      
      if (selectedItems.isNotEmpty) const SizedBox(height: 16),
      
      // 버튼들
      Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: selectedItems.isEmpty 
                  ? null 
                  : () => _addToCart(context, product),
              icon: const Icon(Icons.shopping_cart_outlined),
              label: const Text('장바구니'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: selectedItems.isEmpty ? Colors.grey : Colors.deepOrange),
                foregroundColor: selectedItems.isEmpty ? Colors.grey : Colors.deepOrange,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: selectedItems.isEmpty 
                  ? null 
                  : () => _buyNow(context, product),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: selectedItems.isEmpty ? Colors.grey : Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
              child: const Text('바로 구매'),
            ),
          ),
        ],
      ),
      
      // 선택 안내 메시지
      if (selectedItems.isEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            '상품 옵션을 선택해주세요',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ),
    ],
  );
}


Widget _buildBottomBar(BuildContext context, ProductDetailState productDetailState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
          ),
        ],
      ),
      child: _buildPurchaseButtons(context, productDetailState.product),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        Text(value, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }

  

  void _updateItemQuantity(int index, int newQuantity) {
    ref.read(selectedItemsProvider.notifier).updateQuantity(index, newQuantity);
  }

  void _removeItem(int index) {
    ref.read(selectedItemsProvider.notifier).removeItem(index);
  }


// 임시로 하드코딩해서 테스트
Future<void> _addToCart(BuildContext context, ProductModel product) async {
  final selectedItems = ref.watch(selectedItemsProvider);
  
  if (selectedItems.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('상품 옵션을 선택해주세요.')),
    );
    return;
  }

  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) {
    _showLoginDialog(product);
    return;
  }

  try {
    for (final item in selectedItems) {
      
      // ✅ 임시로 직접 variant ID 확인
      final variantIdToSend = item.variant.id;
      
      await ref.read(cartViewModelProvider.notifier).addProductToCart(
        productId: product.id,
        quantity: item.quantity,
        variantId: variantIdToSend,
      );
    }
    
    if (mounted) {
      ref.read(selectedItemsProvider.notifier).clear();
      _showCartSuccessDialog();
    }
  } catch (e) {
    print('_addToCart 에러: $e');
    if (mounted) {
      _handleCartError(e);
    }
  }
}


// _buyNow 메서드 완전 수정
void _buyNow(BuildContext context, ProductModel product) {
  final selectedItems = ref.watch(selectedItemsProvider);
  
  if (selectedItems.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('상품 옵션을 선택해주세요.'),
        backgroundColor: Colors.orange,
      ),
    );
    return;
  }

  try {
    
    // ✅ 전역 상태에 바로구매 데이터 저장
    final directPurchaseData = DirectPurchaseData(
      productId: product.id,
      productName: product.name,
      productPrice: product.price,
      productDiscountPrice: product.discountPrice,
      productImage: product.imageUrl,
      items: selectedItems.map((item) => {
        'variantId': item.variant.id,
        'variantName': item.variant.name,
        'additionalPrice': item.variant.additionalPrice,
        'quantity': item.quantity,
      }).toList(),
    );
    
    // 전역 상태에 데이터 저장
    ref.read(directPurchaseProvider.notifier).state = directPurchaseData;
    
    
    // ✅ 기존 경로 그대로 사용
    context.go('/shop/cart/checkout');
    
    // 선택 상품 초기화
    ref.read(selectedItemsProvider.notifier).clear();
    
  } catch (e, stackTrace) {
    print('바로구매 에러: $e');
    print('스택 트레이스: $stackTrace');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('바로구매 처리 중 오류가 발생했습니다: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}


  void _showLoginDialog(ProductModel product) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('로그인 필요'),
      content: const Text('장바구니 기능은 로그인 후 이용 가능합니다.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(dialogContext).pop();
            await Future.delayed(const Duration(milliseconds: 100));
            if (mounted) {
              // 로그인 후 장바구니로 이동하도록 설정
              context.go('/login?from=/shop/cart');
            }
          },
          child: const Text('로그인'),
        ),
      ],
    ),
  );
}

// 바로구매 데이터 인코딩 (간단한 JSON)
String _encodeDirectPurchaseData(List<SelectedVariantItem> selectedItems, ProductModel product) {
  // ✅ checkout_screen.dart에서 기대하는 데이터 구조로 변경
  final data = {
    'productId': product.id,
    'productName': product.name,
    'productPrice': product.price,
    'productDiscountPrice': product.discountPrice,
    'productImage': product.imageUrl,
    'items': selectedItems.map((item) => {
      'variantId': item.variant.id,
      'variantName': item.variant.name,
      'additionalPrice': item.variant.additionalPrice,
      'quantity': item.quantity,
    }).toList(),
  };
  
  final jsonString = jsonEncode(data);
  
  final encoded = Uri.encodeComponent(jsonString);
  
  return encoded;
}

  void _showCartSuccessDialog() {
  final selectedItems = ref.read(selectedItemsProvider);
  final totalQuantity = selectedItems.fold<int>(0, (sum, item) => sum + item.quantity);
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('장바구니 추가 완료'),
      content: Text('${totalQuantity}개 상품이 장바구니에 추가되었습니다.\n장바구니로 이동하시겠습니까?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('쇼핑 계속하기'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            context.go('/shop/cart');
          },
          child: const Text('장바구니 보기'),
        ),
      ],
    ),
  );
}

  void _handleCartError(Object error) {
  String message;
  final errorString = error.toString().toLowerCase();

  if (errorString.contains('rls') || errorString.contains('policy') || errorString.contains('auth')) {
    message = '로그인이 필요합니다.';
    // 인증 에러인 경우 로그인 다이얼로그 표시
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showLoginDialog(ref.read(productDetailProvider(widget.productId)).value!.product);
      }
    });
    return;
  } else if (errorString.contains('stock') || errorString.contains('inventory')) {
    message = '재고가 부족합니다.';
  } else if (errorString.contains('network') || errorString.contains('connection')) {
    message = '네트워크 연결을 확인해주세요.';
  } else {
    message = '장바구니 추가에 실패했습니다: ${error.toString()}';
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 3),
    ),
  );
}
}

