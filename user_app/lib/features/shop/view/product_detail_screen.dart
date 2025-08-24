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

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- 상품 이미지 ---
                if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                  Image.network(product.imageUrl!, fit: BoxFit.cover, height: 300)
                else
                  Container(height: 300, color: Colors.grey.shade200, child: const Icon(Icons.image_not_supported, size: 80)),

                // --- 상품 정보 ---
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 16),
                      // ⭐️ 할인가격 표시
                      if (hasDiscount)
                        Text(
                          currencyFormat.format(product.price),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                        ),
                      Text(
                        currencyFormat.format(priceToShow),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Divider(height: 32),
                      _buildInfoRow('배송비', currencyFormat.format(product.shippingFee)),
                      const Divider(height: 32),
                      Text('상품 설명', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(product.description ?? '상세 설명이 없습니다.', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('상품 정보를 불러오는 데 실패했습니다: $e')),
      ),
      // ⭐️ 하단 구매 섹션
      bottomNavigationBar: productAsync.when(
        data: (product) {
           final hasDiscount = product.discountPrice != null && product.discountPrice! < product.price;
           final priceToShow = hasDiscount ? product.discountPrice! : product.price;
           final totalPrice = (priceToShow * _quantity) + product.shippingFee;
          return _buildBottomBar(context, currencyFormat, product, totalPrice);
        },
        // 데이터 로딩 중이거나 에러일 때는 하단 바를 숨김
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  // 정보 행을 만드는 공통 위젯
  Widget _buildInfoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        Text(value, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
  
  // 하단 바 UI
  Widget _buildBottomBar(BuildContext context, NumberFormat currencyFormat, ProductModel product, int totalPrice) {
    // ⭐️ totalPrice 계산 로직을 build 메서드 상단으로 이동하고, 여기서는 상품 가격만 계산합니다.
     final priceToShow = (product.discountPrice != null && product.discountPrice! < product.price)
        ? product.discountPrice!
        : product.price;
     final itemsTotalPrice = priceToShow * _quantity; // ⭐️ 배송비를 제외한 상품 총액
     return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 0, blurRadius: 10),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ⭐️ 수량 표시 및 조절
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('수량', style: TextStyle(fontSize: 16)),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => setState(() {
                        if (_quantity > 1) _quantity--;
                      }),
                    ),
                    Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => setState(() {
                        _quantity++; // TODO: 재고 수량 제한
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // ⭐️ 총 금액
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('총 상품금액', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                // ⭐️ 배송비가 빠진 금액을 표시
                currencyFormat.format(itemsTotalPrice),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepOrange),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // ⭐️ 장바구니, 구매 버튼
          Row(
            children: [
              OutlinedButton(
                // ⭐️ onPressed 부분을 수정합니다.
                onPressed: () {
                  // 1. 현재 로그인 상태를 확인합니다.
                  final currentUser = Supabase.instance.client.auth.currentUser;

                  if (currentUser == null) {
                    // 2. 로그인이 안 되어있으면, 로그인 요청 다이얼로그를 보여줍니다.
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('로그인 필요'),
                        content: const Text('장바구니 기능은 로그인 후 이용 가능합니다. 로그인 페이지로 이동하시겠습니까?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('취소')),
                          TextButton(onPressed: () {
                            Navigator.of(context).pop();
                            context.go('/login');
                          }, child: const Text('로그인')),
                        ],
                      ),
                    );
                    return; // 함수 종료
                  }

                  // 3. 로그인이 되어있으면, 장바구니에 상품을 추가합니다.
                  ref.read(cartViewModelProvider.notifier).addProductToCart(
                        productId: product.id,
                        quantity: _quantity,
                      ).then((_) {
                        // 4. 성공적으로 추가되면, 이동 여부를 묻는 다이얼로그를 보여줍니다.
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                title: const Text('장바구니 추가 완료'),
                                content: const Text('장바구니로 이동하시겠습니까?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('쇼핑 계속하기'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      context.go('/cart');
                                    },
                                    child: const Text('장바구니 보기'),
                                  ),
                                ],
                              ));
                      });
                },
                child: const Text('장바구니'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () { /* TODO: 구매 기능 */ },
                  child: const Text('바로 구매'),
                ),
              ),
              // ⭐️ isUserCreatable이 true일 때만 공동구매 열기 버튼 표시
                    if (product.isUserCreatable) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal, // 버튼 색상 변경
                          ),
                          onPressed: () {
                            // ⭐️ 기존에 만들어둔 공동구매 생성 페이지로 이동
                            context.go('/propose-group-buy');
                          },
                          child: const Text('공동구매 열기'),
                        ),
                      ),
                    ]
            ],
          )
        ],
      ),
    );
  }
}