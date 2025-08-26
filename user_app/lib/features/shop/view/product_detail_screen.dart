// user_app/lib/features/shop/view/product_detail_screen.dart (전체 교체)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/product_model.dart';
import '../../cart/viewmodel/cart_viewmodel.dart';
import '../viewmodel/product_detail_viewmodel.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final int productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;
  bool _isFavorited = false;

  @override
  Widget build(BuildContext context) {
    // ⭐️ ref.listen을 사용하여 장바구니 추가 결과를 감시합니다.
    ref.listen<AsyncValue>(cartViewModelProvider, (_, state) {
      if (state.hasError && !state.isLoading) {
        // 장바구니 추가 실패 시 (예: RLS 정책 위반 등)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('장바구니 추가에 실패했습니다: ${state.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    final productAsync = ref.watch(productDetailProvider(widget.productId));
    final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');

    return Scaffold(
      appBar: AppBar(
        title: const Text('상품 정보'),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: 찜(Wishlist) 기능 연결
              setState(() {
                _isFavorited = !_isFavorited;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isFavorited ? '찜 목록에 추가되었습니다.' : '찜 목록에서 삭제되었습니다.'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            icon: Icon(
              _isFavorited ? Icons.favorite : Icons.favorite_border,
              color: _isFavorited ? Colors.red : null,
            ),
            tooltip: '찜하기',
          ),
        ],
      ),
      body: productAsync.when(
        data: (product) {
          final hasDiscount = product.discountPrice != null && product.discountPrice! < product.price;
          final priceToShow = hasDiscount ? product.discountPrice! : product.price;
          // final totalPrice = (priceToShow * _quantity) + product.shippingFee;

          return LayoutBuilder(
          builder: (context, constraints) {
            bool isWideScreen = constraints.maxWidth > 768;
              return SingleChildScrollView(
                child: isWideScreen
                  ? _buildWideLayout(context, product) // 넓은 화면 UI
                  : _buildNarrowLayout(context, product), // 좁은 화면 UI
            );
          },
        );
      },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('상품 정보를 불러오는 데 실패했습니다: $e')),
      ),
      // ⭐️ 하단 구매 섹션
     bottomNavigationBar: LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 768) {
          return const SizedBox.shrink(); // 넓은 화면에서는 숨김
        }
        return productAsync.when(
          data: (product) => _buildBottomBar(context, product),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
    ),
  );
}

  // 좁은 화면(모바일)용 레이아웃
  Widget _buildNarrowLayout(BuildContext context, ProductModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildProductImage(product),
        _buildProductInfo(context, product),
      ],
    );
  }

  // ⭐️ 넓은 화면(웹/태블릿)용 레이아웃 수정
Widget _buildWideLayout(BuildContext context, ProductModel product) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 48),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ⭐️ 1. 이미지 크기를 줄이기 위해 flex 비율을 2:3으로 조정합니다.
            Expanded(flex: 2, child: _buildProductImage(product)),
            const SizedBox(width: 48),
            Expanded(
              flex: 3, // ⭐️ 정보 영역의 비율을 늘립니다.
              child: _buildProductInfo(context, product, showDescription: false),
            ),
          ],
        ),
        const Divider(height: 64),
        // ⭐️ 2. 상품 설명을 별도의 섹션으로 하단에 추가합니다.
        Text('상품 설명', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Text(product.description ?? '상세 설명이 없습니다.', style: Theme.of(context).textTheme.bodyLarge),
      ],
    ),
  );
}

// ⭐️ 상품 정보 위젯 수정 (설명을 보여줄지 여부를 선택하는 파라미터 추가)
Widget _buildProductInfo(BuildContext context, ProductModel product, {bool showDescription = true}) {
  final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');
  final hasDiscount = product.discountPrice != null && product.discountPrice! < product.price;
  final priceToShow = hasDiscount ? product.discountPrice! : product.price;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(product.name, style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 24),
      if (hasDiscount)
        Text(currencyFormat.format(product.price), style: Theme.of(context).textTheme.titleLarge?.copyWith(decoration: TextDecoration.lineThrough, color: Colors.grey)),
      Text(currencyFormat.format(priceToShow), style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
      const Divider(height: 48),
      _buildInfoRow('배송비', currencyFormat.format(product.shippingFee)),
      const SizedBox(height: 24),
      // ⭐️ 구매 섹션을 여기에 포함시켜 정보와 함께 보여줍니다.
      _buildPurchaseSection(context, product),
      
      // ⭐️ 모바일 뷰에서만 상품 설명을 여기에 표시합니다.
      if (showDescription) ...[
        const Divider(height: 32, indent: 0, endIndent: 0),
        Text('상품 설명', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Text(product.description ?? '상세 설명이 없습니다.', style: Theme.of(context).textTheme.bodyLarge),
      ]
    ],
  );
}

  // 공통 위젯: 상품 이미지
  Widget _buildProductImage(ProductModel product) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: (product.imageUrl != null && product.imageUrl!.isNotEmpty)
          ? Image.network(product.imageUrl!, fit: BoxFit.cover)
          : Container(height: 300, color: Colors.grey.shade200, child: const Icon(Icons.image_not_supported, size: 80)),
    );
  }

  

  // 공통 위젯: 구매 섹션 (수량, 총액, 버튼)
  Widget _buildPurchaseSection(BuildContext context, ProductModel product) {
    final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');
    final hasDiscount = product.discountPrice != null && product.discountPrice! < product.price;
    final priceToShow = hasDiscount ? product.discountPrice! : product.price;
    final totalPrice = (priceToShow * _quantity) + product.shippingFee;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('수량', style: TextStyle(fontSize: 16)),
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.remove), onPressed: () => setState(() { if (_quantity > 1) _quantity--; })),
                  Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.add), onPressed: () => setState(() { _quantity++; })),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('총 상품금액', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(currencyFormat.format(totalPrice), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            OutlinedButton(onPressed: () => _addToCart(product), child: const Text('장바구니')),
            const SizedBox(width: 8),
            Expanded(child: ElevatedButton(onPressed: () { /* TODO: 구매 기능 */ }, child: const Text('바로 구매'))),
            if (product.isUserCreatable) ...[
              const SizedBox(width: 8),
              Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.teal), onPressed: () => context.go('/propose-group-buy'), child: const Text('공동구매 열기'))),
            ]
          ],
        )
      ],
    );
  }

  // 모바일용 하단 바
  Widget _buildBottomBar(BuildContext context, ProductModel product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 0, blurRadius: 10)],
      ),
      child: _buildPurchaseSection(context, product),
    );
  }

  // 정보 행 위젯
  Widget _buildInfoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        Text(value, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
  
  // 장바구니 추가 로직
  void _addToCart(ProductModel product) {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('로그인 필요'),
                content: const Text('장바구니 기능은 로그인 후 이용 가능합니다.'),
                actions: [
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('취소')),
                  TextButton(onPressed: () { Navigator.of(context).pop(); context.go('/login?from=/shop/${product.id}'); }, child: const Text('로그인')),
                ],
              ));
      return;
    }
    ref.read(cartViewModelProvider.notifier).addProductToCart(productId: product.id, quantity: _quantity)
        .then((_) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                  title: const Text('장바구니 추가 완료'),
                  content: const Text('장바구니로 이동하시겠습니까?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('쇼핑 계속하기')),
                    TextButton(onPressed: () { Navigator.of(context).pop(); context.go('/shop/cart'); }, child: const Text('장바구니 보기')),
                  ]));
    });
  }
}