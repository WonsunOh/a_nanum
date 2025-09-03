// user_app/lib/features/order/view/checkout_screen.dart (전체 교체)

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../data/models/cart_item_model.dart';
import '../../cart/viewmodel/cart_viewmodel.dart';
import '../../payment/views/portone_web_html_screen.dart';
import '../viewmodel/order_viewmodel.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
// _submitOrder 메서드를 단순하게 수정
Future<void> _submitOrder() async {
  if (!_formKey.currentState!.validate()) return;

  final cartState = ref.read(cartViewModelProvider).valueOrNull;
  if (cartState == null || cartState.selectedItemIds.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('주문할 상품을 선택해주세요.')),
    );
    return;
  }

  final List<CartItemModel> selectedItems = cartState.items
      .where((item) => cartState.selectedItemIds.contains(item.id))
      .cast<CartItemModel>()
      .toList();

  // 결제 금액 계산
  const int shippingFee = 3000;
  const int freeShippingThreshold = 50000;
  final int subtotal = selectedItems.fold(0, (sum, item) {
    final hasDiscount = item.product?.discountPrice != null && 
                       item.product!.discountPrice! < item.product!.price;
    final priceToShow = hasDiscount ? 
                       item.product!.discountPrice! : 
                       item.product!.price;
    return sum + (priceToShow * item.quantity);
  });
  final int currentShippingFee = (subtotal >= freeShippingThreshold || subtotal == 0) ? 0 : shippingFee;
  final int totalAmount = subtotal + currentShippingFee;

  print('🚀 결제 확인 화면 표시');

  // ⭐️ 결제 확인 화면 표시
  final confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog.fullscreen(
      child: _buildPaymentConfirmationScreen(totalAmount, selectedItems),
    ),
  );

  print('결제 확인 결과: $confirmed');

  // ⭐️ 확인되면 바로 결제 처리
  if (confirmed == true) {
    await _processPayment(selectedItems, totalAmount, currentShippingFee);
  }
} 
  
  // ⭐️ 결제 확인 전체 화면 위젯
 // _buildPaymentConfirmationScreen 메서드를 단순하게 수정
Widget _buildPaymentConfirmationScreen(int totalAmount, List<CartItemModel> selectedItems) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('결제 확인'),
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          print('❌ 결제 취소 버튼 클릭');
          Navigator.of(context, rootNavigator: true).pop(false);
        },
      ),
    ),
    body: Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: _buildPaymentConfirmationCard(totalAmount, selectedItems),
          ),
        ),
        // 하단 결제 버튼
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    print('❌ 취소 버튼 클릭');
                    Navigator.of(context, rootNavigator: true).pop(false);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('취소'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    print('💳 결제하기 버튼 클릭');
                    // ⭐️ 단순하게 true를 반환하여 결제 진행 신호
                    Navigator.of(context, rootNavigator: true).pop(true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text('${_formatAmount(totalAmount)}원 결제하기'),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  // ⭐️ 결제 확인 카드 위젯
  Widget _buildPaymentConfirmationCard(int totalAmount, List selectedItems) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payment, color: Colors.blue),
                const SizedBox(width: 12),
                Text(
                  '결제 정보',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildPaymentInfoRow('선택 상품', '${selectedItems.length}개'),
            _buildPaymentInfoRow('받는 분', _nameController.text),
            _buildPaymentInfoRow('연락처', _phoneController.text),
            _buildPaymentInfoRow('배송지', _addressController.text),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '총 결제금액',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_formatAmount(totalAmount)}원',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                border: Border.all(color: Colors.amber),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '테스트 환경으로 실제 결제는 발생하지 않습니다.',
                      style: TextStyle(color: Colors.amber[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ⭐️ 결제 정보 행 위젯
  Widget _buildPaymentInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Flexible(
            child: Text(
              value, 
              style: const TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

 Future<void> _processPayment(
  List<CartItemModel> selectedItems, 
  int totalAmount, 
  int currentShippingFee
) async {
  try {
    print('💳 PortOne 결제 처리 시작: ${totalAmount}원');
    
    // 사용자 이메일 (임시로 생성, 실제로는 사용자 프로필에서 가져와야 함)
    final userEmail = "${_phoneController.text}@temp.com";
    
    Map<String, dynamic>? paymentResult;
    
    // _processPayment 메서드에서 호출 부분 수정
if (kIsWeb) {
  // 웹에서는 HTML 기반 PortOne 결제 사용
  paymentResult = await showDialog<Map<String, dynamic>>(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog.fullscreen(
      child: PortOneWebHtmlScreen(
        totalAmount: totalAmount,
        orderName: '소분쇼핑몰 주문 ${selectedItems.length}건',
        customerName: _nameController.text,
        customerPhone: _phoneController.text,
        customerEmail: userEmail,
        customerAddress: _addressController.text,
      ),
    ),
  );
} else {
      // 모바일에서는 네이티브 SDK 사용 (추후 구현)
      // paymentResult = await _requestMobilePayment(...);
      
      // 임시로 웹 버전 사용
      paymentResult = await showDialog<Map<String, dynamic>>(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog.fullscreen(
          child: PortOneWebHtmlScreen(
            totalAmount: totalAmount,
            orderName: '소분쇼핑몰 주문 ${selectedItems.length}건',
            customerName: _nameController.text,
            customerPhone: _phoneController.text,
            customerEmail: userEmail,
            customerAddress: _addressController.text,
          ),
        ),
      );
    }
    
    print('🔍 PortOne 결제 결과: $paymentResult');
    
    if (paymentResult != null && paymentResult['success'] == true) {
      print('✅ PortOne 결제 성공: ${paymentResult['paymentId']}');
      
      // 결제 성공 시 주문 생성
      final success = await ref.read(orderViewModelProvider.notifier).createOrder(
        cartItems: selectedItems,
        totalAmount: totalAmount,
        shippingFee: currentShippingFee,
        recipientName: _nameController.text,
        recipientPhone: _phoneController.text,
        shippingAddress: _addressController.text,
      );

      if (success && mounted) {
        context.go('/shop');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '결제 및 주문 완료!',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('${_formatAmount(totalAmount)}원 결제 완료'),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } else if (paymentResult != null && paymentResult['cancelled'] == true) {
      // 사용자가 결제 취소
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('결제가 취소되었습니다.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {
      // 결제 실패
      final errorMessage = paymentResult?['error'] ?? '결제 처리 중 오류가 발생했습니다.';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('결제 실패: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  } catch (e, stackTrace) {
    print('❌ PortOne 결제 처리 에러: $e');
    print('📍 스택 트레이스: $stackTrace');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('결제 처리 중 오류: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
  
  
  // ⭐️ 금액 포맷팅 헬퍼 함수
  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('주문/결제')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 768;
          return isWideScreen
              ? _buildWideLayout() // 넓은 화면 UI
              : _buildNarrowLayout(); // 좁은 화면 UI
        },
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 768) {
            return const SizedBox.shrink(); // 넓은 화면에서는 숨김
          }
          final orderState = ref.watch(orderViewModelProvider);
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: orderState.isLoading ? null : _submitOrder,
              child: orderState.isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('결제하기'),
            ),
          );
        },
      ),
    );
  }

  // 좁은 화면(모바일)용 레이아웃
  Widget _buildNarrowLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildShippingForm(),
          const Divider(height: 48),
          _buildOrderSummary(),
        ],
      ),
    );
  }

  // 넓은 화면(웹)용 레이아웃
  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 왼쪽: 배송지 정보 입력 폼
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: _buildShippingForm(),
          ),
        ),
        const VerticalDivider(width: 1),
        // 오른쪽: 주문 요약
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32.0),
                  child: _buildOrderSummary(),
                ),
              ),
              // ⭐️ 넓은 화면에서는 결제 버튼이 여기에 위치합니다.
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Consumer(
                  builder: (context, ref, child) {
                    final orderState = ref.watch(orderViewModelProvider);
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: orderState.isLoading ? null : _submitOrder,
                      child: orderState.isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('결제하기'),
                    );
                  }
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 공통 위젯: 배송지 정보 폼
  Widget _buildShippingForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('배송지 정보', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: '받는 사람'), validator: (v) => v!.isEmpty ? '필수' : null),
          const SizedBox(height: 12),
          TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: '연락처'), keyboardType: TextInputType.phone, validator: (v) => v!.isEmpty ? '필수' : null),
          const SizedBox(height: 12),
          TextFormField(controller: _addressController, decoration: const InputDecoration(labelText: '배송 주소'), validator: (v) => v!.isEmpty ? '필수' : null),
        ],
      ),
    );
  }

  // 공통 위젯: 주문 요약
  Widget _buildOrderSummary() {
    final cartAsync = ref.watch(cartViewModelProvider);
    final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');

    return cartAsync.when(
      data: (cartState) {
        final selectedItems = cartState.items.where((item) => cartState.selectedItemIds.contains(item.id)).toList();
        if (selectedItems.isEmpty) return const Text('주문할 상품이 없습니다.');

        const int shippingFee = 3000;
        const int freeShippingThreshold = 50000;
        final int subtotal = selectedItems.fold(0, (sum, item) {
          final price = item.product?.discountPrice ?? item.product?.price ?? 0;
          return sum + (price * item.quantity);
        });
        final int currentShippingFee = (subtotal >= freeShippingThreshold || subtotal == 0) ? 0 : shippingFee;
        final int totalAmount = subtotal + currentShippingFee;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('주문 요약', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...selectedItems.map((item) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Image.network(item.product?.imageUrl ?? '', width: 40, fit: BoxFit.cover),
              title: Text(item.product?.name ?? ''),
              trailing: Text('${item.quantity}개'),
            )),
            const Divider(height: 32),
            _buildPriceRow('총 상품 금액', currencyFormat.format(subtotal)),
            const SizedBox(height: 8),
            _buildPriceRow('배송비', currencyFormat.format(currentShippingFee)),
            const Divider(height: 24),
            _buildPriceRow('최종 결제 금액', currencyFormat.format(totalAmount), isTotal: true),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => const Text('장바구니 정보를 불러올 수 없습니다.'),
    );
  }
  
  // 가격 행을 만드는 공통 위젯
  Widget _buildPriceRow(String title, String price, {bool isTotal = false}) {
    final style = TextStyle(
      fontSize: isTotal ? 18 : 14,
      fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: style),
        Text(price, style: style.copyWith(color: isTotal ? Colors.deepOrange : null)),
      ],
    );
  }



}