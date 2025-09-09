// user_app/lib/features/order/view/checkout_screen.dart (바로구매 기능 포함 완전 버전)

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../data/models/cart_item_model.dart';
import '../../../providers/user_provider.dart';
import '../../cart/viewmodel/cart_viewmodel.dart';
import '../../payment/views/portone_web_html_screen.dart';
import '../../shop/view/product_detail_screen.dart';
import '../viewmodel/order_viewmodel.dart';
import '../widgets/juso_address_search_widget.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _postcodeController = TextEditingController();
  final _addressController = TextEditingController();
  final _detailAddressController = TextEditingController();
  final _deliveryRequestController = TextEditingController();

  bool _isAutoFilled = false;
  bool _isEditMode = false;

  // 바로구매 관련 변수
  Map<String, dynamic>? directPurchaseData;
  bool get isDirectPurchase => directPurchaseData != null;

  @override
  void initState() {
    super.initState();

    // ✅ 바로구매 모드 확인과 사용자 정보 자동 입력을 순차적으로 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDirectPurchaseMode();

      // ✅ 조금 더 긴 지연시간으로 사용자 정보 로딩 완료 대기
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _tryAutoFillUserInfo();
        }
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _postcodeController.dispose();
    _addressController.dispose();
    _detailAddressController.dispose();
    _deliveryRequestController.dispose();
    super.dispose();
  }

  // 바로구매 모드 확인
  // _checkDirectPurchaseMode 메서드 전체 수정
  // _checkDirectPurchaseMode 메서드 수정
  void _checkDirectPurchaseMode() {
    // ✅ 전역 상태에서 바로구매 데이터 확인
    final directData = ref.read(directPurchaseProvider);

    if (directData != null) {
      // 데이터 구조를 기존 방식에 맞게 변환
      directPurchaseData = directData.toJson();

      if (mounted) {
        setState(() {}); // UI 업데이트
      }

      // 바로구매 상품이 없는 경우 장바구니로 리다이렉트
      final items = directPurchaseData!['items'] as List?;
      if (items == null || items.isEmpty) {
        context.go('/shop/cart');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('주문할 상품이 없습니다.')));
      } else {
        // ✅ 사용 후 전역 상태 클리어
        ref.read(directPurchaseProvider.notifier).state = null;
      }
    } else {
      // ✅ 기존 URL 파라미터 방식도 지원 (호환성)
      final uri = GoRouterState.of(context).uri;
      final directParam = uri.queryParameters['direct'];

      if (directParam != null) {
        try {
          final decodedString = Uri.decodeComponent(directParam);
          directPurchaseData = jsonDecode(decodedString);

          if (mounted) {
            setState(() {});
          }

          final items = directPurchaseData!['items'] as List?;
          if (items == null || items.isEmpty) {
            context.go('/shop/cart');
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('주문할 상품이 없습니다.')));
          }
        } catch (e) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('주문 정보를 불러올 수 없습니다: $e')));
              context.go('/shop/cart');
            }
          });
        }
      }
    }
  }

  // 레벨 2 이상 사용자 정보 자동 입력
  void _tryAutoFillUserInfo() {
    // ✅ userProvider를 watch로 변경하여 실시간 상태 감지
    final userProfileAsync = ref.read(userProvider);

    userProfileAsync.when(
      data: (userProfile) {
        if (userProfile != null && userProfile.level >= 2) {
          setState(() {
            _nameController.text =
                userProfile.fullName ?? userProfile.nickname ?? '';

            if (userProfile.postcode != null &&
                userProfile.postcode!.isNotEmpty) {
              _postcodeController.text = userProfile.postcode!;
            }

            if (userProfile.address != null &&
                userProfile.address!.isNotEmpty) {
              _parseAndFillAddress(userProfile.address!);
            }

            if (userProfile.phoneNumber != null &&
                userProfile.phoneNumber!.isNotEmpty) {
              _phoneController.text = userProfile.phoneNumber!;
            }

            _isAutoFilled = true;
          });

          if (userProfile.address != null && userProfile.address!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '레벨 ${userProfile.level} 회원 혜택으로 배송 정보가 자동 입력되었습니다!',
                      ),
                    ),
                  ],
                ),
                backgroundColor: isDirectPurchase
                    ? Colors.orange.shade600
                    : Colors.blue.shade600,
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: '수정',
                  textColor: Colors.white,
                  onPressed: () {
                    setState(() => _isEditMode = true);
                  },
                ),
              ),
            );
          }
        }
      },
      loading: () {
        // ✅ 로딩 중일 때 재시도
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _tryAutoFillUserInfo();
          }
        });
      },
      error: (error, stackTrace) {
        print('사용자 프로필 로드 에러: $error');
      },
    );
  }

  // 주소 파싱
  void _parseAndFillAddress(String fullAddress) {
    final regexWithPostcode = RegExp(
      r'\((\d{5})\)\s*(.+?)(\s+\d+동\s*\d+호|\s+\d+호|\s+\d+층.*|\s+아파트.*|\s+빌딩.*)?$',
    );
    final matchWithPostcode = regexWithPostcode.firstMatch(fullAddress);

    if (matchWithPostcode != null) {
      final postcode = matchWithPostcode.group(1) ?? '';
      final mainAddress = matchWithPostcode.group(2)?.trim() ?? '';
      final detailAddress = matchWithPostcode.group(3)?.trim() ?? '';

      if (postcode.isNotEmpty && _postcodeController.text.isEmpty) {
        _postcodeController.text = postcode;
      }
      _addressController.text = mainAddress;
      _detailAddressController.text = detailAddress;
      return;
    }

    final regexWithoutPostcode = RegExp(r'^(.+?)\s+(\d+동\s*\d+호|\d+호|\d+층.*)$');
    final matchWithoutPostcode = regexWithoutPostcode.firstMatch(fullAddress);

    if (matchWithoutPostcode != null) {
      final mainAddress = matchWithoutPostcode.group(1)?.trim() ?? '';
      final detailAddress = matchWithoutPostcode.group(2)?.trim() ?? '';

      _addressController.text = mainAddress;
      _detailAddressController.text = detailAddress;
      return;
    }

    _addressController.text = fullAddress;
  }

  // 주소 검색 팝업
  void _openAddressSearch() {
    final isWideScreen = MediaQuery.of(context).size.width > 768;

    if (isWideScreen) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 100,
            vertical: 40,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 600,
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: JusoAddressSearchWidget(
              onAddressSelected: _onAddressSelected,
            ),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: JusoAddressSearchWidget(onAddressSelected: _onAddressSelected),
        ),
      );
    }
  }

  // 주소 선택 완료 처리
  void _onAddressSelected(Map<String, String> addressData) {
    setState(() {
      _postcodeController.text = addressData['zonecode'] ?? '';
      final roadAddress = addressData['roadAddress'] ?? '';
      final jibunAddress = addressData['jibunAddress'] ?? '';
      _addressController.text = roadAddress.isNotEmpty
          ? roadAddress
          : jibunAddress;
      _isEditMode = true;
    });

    FocusScope.of(context).requestFocus(FocusNode());
  }

  // 전체 주소 문자열 생성
  String get _fullAddress {
    final postcode = _postcodeController.text;
    final address = _addressController.text;
    final detailAddress = _detailAddressController.text;

    return '($postcode) $address $detailAddress'.trim();
  }

  // 바로구매 소계 계산
  int _calculateDirectPurchaseSubtotal() {
    final basePrice =
        directPurchaseData!['productDiscountPrice'] ??
        directPurchaseData!['productPrice'];
    final items = directPurchaseData!['items'] as List;

    // fold의 초기값이 int 타입(0)이므로, fold가 반환하는 타입은 int가 됩니다.
    // 따라서 계산의 최종 결과를 .toInt()로 변환하여 타입을 일치시켜야 합니다.
    return items.fold<int>(0, (sum, item) {
      final variantPrice = item['additionalPrice'] ?? 0;
      final quantity = item['quantity'];

      // 각 항목의 소계는 double일 수 있으므로 num 타입으로 계산합니다.
      final num itemSubtotal = (basePrice + variantPrice) * quantity;

      // 최종적으로 sum(int)에 더하기 전에 itemSubtotal을 int로 변환합니다.
      return sum + itemSubtotal.toInt();
    });
  }

  // 장바구니 소계 계산
  int _calculateCartSubtotal(List<CartItemModel> items) {
    return items.fold(0, (sum, item) {
      final basePrice = item.product?.discountPrice ?? item.product?.price ?? 0;
      final variantPrice = item.variantAdditionalPrice ?? 0;
      final finalPrice = basePrice + variantPrice;
      return sum + (finalPrice * item.quantity);
    });
  }

  // 주문 제출
  // _submitOrder() 메서드에서 해당 부분 수정
  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    List<dynamic> orderItems;
    int subtotal;

    if (isDirectPurchase) {
      // 바로구매 모드
      orderItems = directPurchaseData!['items'];
      subtotal = _calculateDirectPurchaseSubtotal(); // 바로구매용 계산 메서드 사용

      if (orderItems.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('주문할 상품 정보가 없습니다.')));
        return;
      }
    } else {
      // 장바구니 모드
      final cartState = ref.read(cartViewModelProvider).valueOrNull;
      if (cartState == null || cartState.selectedItemIds.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('주문할 상품을 선택해주세요.')));
        return;
      }

      final cartItems = cartState.items
          .where((item) => cartState.selectedItemIds.contains(item.id))
          .cast<CartItemModel>()
          .toList();

      orderItems = cartItems; // 타입을 맞춰주기 위해 분리
      subtotal = _calculateCartSubtotal(cartItems); // CartItemModel 리스트 전달
    }

    const int shippingFee = 3000;
    const int freeShippingThreshold = 50000;
    final int currentShippingFee = (subtotal >= freeShippingThreshold)
        ? 0
        : shippingFee;
    final int totalAmount = subtotal + currentShippingFee;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog.fullscreen(
        child: _buildPaymentConfirmationScreen(totalAmount, orderItems),
      ),
    );

    if (confirmed == true) {
      await _processPayment(orderItems, totalAmount, currentShippingFee);
    }
  }

  // 결제 확인 화면
  Widget _buildPaymentConfirmationScreen(int totalAmount, List<dynamic> items) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isDirectPurchase ? '바로구매 결제 확인' : '결제 확인'),
        backgroundColor: isDirectPurchase
            ? Colors.orange.shade600
            : Colors.blue.shade600,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () =>
              Navigator.of(context, rootNavigator: true).pop(false),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: _buildPaymentConfirmationCard(totalAmount, items),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).pop(false),
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
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDirectPurchase
                          ? Colors.orange.shade600
                          : Colors.blue.shade600,
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

  // 결제 확인 카드
  Widget _buildPaymentConfirmationCard(int totalAmount, List<dynamic> items) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isDirectPurchase ? Icons.flash_on : Icons.payment,
                  color: isDirectPurchase
                      ? Colors.orange.shade600
                      : Colors.blue.shade600,
                ),
                const SizedBox(width: 12),
                Text(
                  isDirectPurchase ? '바로구매 결제 정보' : '결제 정보',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildPaymentInfoRow('선택 상품', '${items.length}개'),
            _buildPaymentInfoRow('받는 분', _nameController.text),
            _buildPaymentInfoRow('연락처', _phoneController.text),
            _buildPaymentInfoRow(
              '배송지',
              '${_addressController.text} ${_detailAddressController.text}',
            ),
            if (_deliveryRequestController.text.isNotEmpty)
              _buildPaymentInfoRow('배송 요청사항', _deliveryRequestController.text),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '총 결제금액',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                color: Colors.amber.shade50,
                border: Border.all(color: Colors.amber),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '테스트 환경으로 실제 결제는 발생하지 않습니다.',
                      style: TextStyle(color: Colors.amber.shade700),
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

  // 결제 처리
  Future<void> _processPayment(
    List<dynamic> items,
    int totalAmount,
    int currentShippingFee,
  ) async {
    try {
      final userEmail = "${_phoneController.text}@temp.com";

      Map<String, dynamic>? paymentResult;

      paymentResult = await showDialog<Map<String, dynamic>>(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog.fullscreen(
          child: PortOneWebHtmlScreen(
            totalAmount: totalAmount,
            orderName: isDirectPurchase
                ? '바로구매 ${items.length}건'
                : '소분쇼핑몰 주문 ${items.length}건',
            customerName: _nameController.text,
            customerPhone: _phoneController.text,
            customerEmail: userEmail,
            customerAddress: _addressController.text,
          ),
        ),
      );

      if (paymentResult != null && paymentResult['success'] == true) {
        // ✅ 결제 성공 시 실제 주문 생성
        bool orderSuccess = false;

        if (isDirectPurchase) {
          // 바로구매 주문 생성
          orderSuccess = await _createDirectPurchaseOrder(
            items: items,
            totalAmount: totalAmount,
            currentShippingFee: currentShippingFee,
            paymentId: paymentResult['paymentId'],
          );
        } else {
          // 장바구니 주문 생성
          orderSuccess = await _createCartOrder(
            items: items.cast<CartItemModel>(),
            totalAmount: totalAmount,
            currentShippingFee: currentShippingFee,
            paymentId: paymentResult['paymentId'],
          );
        }

        if (mounted && orderSuccess) {
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
                        Text(
                          isDirectPurchase ? '바로구매 주문 완료!' : '주문 완료!',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('${_formatAmount(totalAmount)}원 결제 및 주문 완료'),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('결제는 완료되었으나 주문 생성에 실패했습니다. 고객센터에 문의해주세요.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else if (paymentResult != null && paymentResult['cancelled'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('결제가 취소되었습니다.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
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
      print('결제 처리 에러: $e');
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

  /// 장바구니 주문 생성
  Future<bool> _createCartOrder({
    required List<CartItemModel> items,
    required int totalAmount,
    required int currentShippingFee,
    required String paymentId,
  }) async {
    try {
      final success = await ref
          .read(orderViewModelProvider.notifier)
          .createOrder(
            cartItems: items,
            totalAmount: totalAmount,
            shippingFee: currentShippingFee,
            recipientName: _nameController.text,
            recipientPhone: _phoneController.text,
            shippingAddress: _fullAddress,
            paymentId: paymentId,
          );

      if (success) {
        print('✅ 장바구니 주문 생성 성공 - PaymentID: $paymentId');
      }

      return success;
    } catch (e) {
      print('❌ 장바구니 주문 생성 실패: $e');
      return false;
    }
  }

  /// 바로구매 주문 생성
  Future<bool> _createDirectPurchaseOrder({
    required List<dynamic> items,
    required int totalAmount,
    required int currentShippingFee,
    required String paymentId,
  }) async {
    try {
      // 바로구매 데이터를 CartItemModel 형태로 변환
      final cartItems = await _convertDirectPurchaseToCartItems(items);

      final success = await ref
          .read(orderViewModelProvider.notifier)
          .createOrder(
            cartItems: cartItems,
            totalAmount: totalAmount,
            shippingFee: currentShippingFee,
            recipientName: _nameController.text,
            recipientPhone: _phoneController.text,
            shippingAddress: _fullAddress,
            paymentId: paymentId,
          );

      if (success) {
        print('✅ 바로구매 주문 생성 성공 - PaymentID: $paymentId');
      }

      return success;
    } catch (e) {
      print('❌ 바로구매 주문 생성 실패: $e');
      return false;
    }
  }

  /// 바로구매 데이터를 CartItemModel로 변환
  Future<List<CartItemModel>> _convertDirectPurchaseToCartItems(
    List<dynamic> items,
  ) async {
    // 이 메서드는 바로구매 데이터 구조에 맞게 구현해야 합니다
    // directPurchaseData의 구조를 확인하여 CartItemModel로 변환
    // 현재는 간단한 예시로 작성

    return []; // TODO: 실제 변환 로직 구현 필요
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Row(
          children: [
            if (isDirectPurchase) ...[
              Icon(Icons.flash_on, color: Colors.orange.shade600, size: 20),
              const SizedBox(width: 8),
              const Text('바로구매'),
            ] else
              const Text('주문/결제'),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 768;
          return isWideScreen ? _buildWideLayout() : _buildNarrowLayout();
        },
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 768) {
            return const SizedBox.shrink();
          }
          final orderState = ref.watch(orderViewModelProvider);
          return Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDirectPurchase
                    ? Colors.orange.shade600
                    : Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: orderState.isLoading ? null : _submitOrder,
              child: orderState.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isDirectPurchase) ...[
                          const Icon(Icons.flash_on, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            '바로결제',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ] else
                          const Text(
                            '결제하기',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  // 좁은 화면용 레이아웃
  Widget _buildNarrowLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildShippingForm(),
          const SizedBox(height: 8),
          _buildOrderSummary(),
        ],
      ),
    );
  }

  // 넓은 화면용 레이아웃
  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: SingleChildScrollView(child: _buildShippingForm()),
        ),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(child: _buildOrderSummary()),
              ),
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Consumer(
                  builder: (context, ref, child) {
                    final orderState = ref.watch(orderViewModelProvider);
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDirectPurchase
                            ? Colors.orange.shade600
                            : Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: orderState.isLoading ? null : _submitOrder,
                      child: orderState.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              isDirectPurchase ? '바로결제' : '결제하기',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 배송지 정보 폼
  Widget _buildShippingForm() {
    final userProfileAsync = ref.watch(userProvider);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDirectPurchase
                          ? Colors.orange.shade50
                          : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.local_shipping,
                      color: isDirectPurchase
                          ? Colors.orange.shade600
                          : Colors.blue.shade600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '배송지 정보',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      userProfileAsync.when(
                        data: (profile) {
                          if (profile != null &&
                              profile.level >= 2 &&
                              _isAutoFilled) {
                            return Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  size: 14,
                                  color: Colors.blue.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '레벨 ${profile.level} 회원 혜택 적용',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (_isAutoFilled && !_isEditMode)
                    TextButton.icon(
                      onPressed: () => setState(() => _isEditMode = true),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('수정'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue.shade600,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 24),

              // 받는 사람
              _buildTextField(
                controller: _nameController,
                label: '받는 사람',
                hint: '받는 분의 성함을 입력하세요',
                icon: Icons.person_outline,
                readOnly: _isAutoFilled && !_isEditMode,
                validator: (v) => v!.isEmpty ? '받는 사람을 입력해주세요' : null,
              ),

              const SizedBox(height: 16),

              // 연락처
              _buildTextField(
                controller: _phoneController,
                label: '연락처',
                hint: '010-1234-5678',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                readOnly: _isAutoFilled && !_isEditMode,
                validator: (v) => v!.isEmpty ? '연락처를 입력해주세요' : null,
              ),

              const SizedBox(height: 24),

              // 주소 섹션
              const Text(
                '배송 주소',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              // 우편번호 + 주소 찾기
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      controller: _postcodeController,
                      label: '우편번호',
                      hint: '12345',
                      icon: Icons.markunread_mailbox_outlined,
                      readOnly: true,
                      validator: (v) => v!.isEmpty ? '주소를 검색해주세요' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _openAddressSearch,
                      icon: const Icon(Icons.search, size: 18),
                      label: const Text('주소 찾기'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDirectPurchase
                            ? Colors.orange.shade600
                            : Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 기본 주소
              _buildTextField(
                controller: _addressController,
                label: '기본 주소',
                hint: '주소 검색을 통해 자동 입력됩니다',
                icon: Icons.location_on_outlined,
                readOnly: true,
                validator: (v) => v!.isEmpty ? '주소를 검색해주세요' : null,
              ),

              const SizedBox(height: 16),

              // 상세 주소
              _buildTextField(
                controller: _detailAddressController,
                label: '상세 주소',
                hint: '동/호수를 입력하세요 (예: 101동 1201호)',
                icon: Icons.home_outlined,
                validator: (v) => v!.isEmpty ? '상세 주소를 입력해주세요' : null,
              ),

              const SizedBox(height: 24),

              // 배송 요청사항
              const Text(
                '배송 요청사항',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _deliveryRequestController,
                label: '배송 요청사항 (선택)',
                hint: '예: 문 앞에 놓아주세요, 부재 시 경비실에 맡겨주세요',
                icon: Icons.comment_outlined,
                maxLines: 2,
                isRequired: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 텍스트 필드 위젯
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool readOnly = false,
    bool isRequired = true,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDirectPurchase
                ? Colors.orange.shade600
                : Colors.blue.shade600,
            width: 2,
          ),
        ),
        filled: readOnly,
        fillColor: readOnly ? Colors.grey.shade50 : null,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: maxLines > 1 ? 16 : 16,
        ),
      ),
      keyboardType: keyboardType,
      readOnly: readOnly,
      validator: isRequired ? validator : null,
    );
  }

  // 주문 요약
  Widget _buildOrderSummary() {
    // 바로구매 모드인 경우
    if (isDirectPurchase && directPurchaseData != null) {
      return _buildDirectPurchaseOrderSummary();
    }

    // 장바구니 모드 (기존 로직)
    final cartAsync = ref.watch(cartViewModelProvider);
    final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: cartAsync.when(
        data: (cartState) {
          final selectedItems = cartState.items
              .where((item) => cartState.selectedItemIds.contains(item.id))
              .toList();
          if (selectedItems.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Text('주문할 상품이 없습니다.'),
            );
          }

          const int shippingFee = 3000;
          const int freeShippingThreshold = 50000;

          final int subtotal = _calculateCartSubtotal(selectedItems);
          final int currentShippingFee = (subtotal >= freeShippingThreshold)
              ? 0
              : shippingFee;
          final int totalAmount = subtotal + currentShippingFee;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.receipt_long,
                        color: Colors.green.shade600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      '주문 요약',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 상품 리스트
                ...selectedItems.map((item) {
                  final product = item.product;
                  if (product == null) return const SizedBox.shrink();

                  final basePrice = product.discountPrice ?? product.price;
                  final variantPrice = item.variantAdditionalPrice ?? 0;
                  final finalPrice = basePrice + variantPrice;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            product.imageUrl ?? '',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (item.variantName != null) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item.variantName!,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                '${currencyFormat.format(finalPrice)} × ${item.quantity}개',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          currencyFormat.format(finalPrice * item.quantity),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),

                const Divider(height: 32),
                _buildPriceRow('총 상품 금액', currencyFormat.format(subtotal)),
                const SizedBox(height: 8),
                _buildPriceRow(
                  '배송비',
                  currencyFormat.format(currentShippingFee),
                ),
                const Divider(height: 24),
                _buildPriceRow(
                  '최종 결제 금액',
                  currencyFormat.format(totalAmount),
                  isTotal: true,
                ),

                if (subtotal >= freeShippingThreshold) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_shipping,
                          color: Colors.green.shade600,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '무료배송 혜택 적용',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, st) => const Padding(
          padding: EdgeInsets.all(24),
          child: Text('장바구니 정보를 불러올 수 없습니다.'),
        ),
      ),
    );
  }

  // 바로구매 주문 요약
  Widget _buildDirectPurchaseOrderSummary() {
    final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');
    final items = directPurchaseData!['items'] as List;
    final basePrice =
        directPurchaseData!['productDiscountPrice'] ??
        directPurchaseData!['productPrice'];

    const int shippingFee = 3000;
    const int freeShippingThreshold = 50000;
    final int subtotal = _calculateDirectPurchaseSubtotal();
    final int currentShippingFee = (subtotal >= freeShippingThreshold)
        ? 0
        : shippingFee;
    final int totalAmount = subtotal + currentShippingFee;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 (바로구매 표시)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.flash_on, color: Colors.orange.shade600),
                ),
                const SizedBox(width: 12),
                const Text(
                  '바로구매 주문',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 상품 정보
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // 상품 이미지
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          directPurchaseData!['productImage'] ?? '',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          directPurchaseData!['productName'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 선택된 옵션들
                  ...items.map((item) {
                    final variantPrice = item['additionalPrice'] ?? 0;
                    final quantity = item['quantity'];
                    final itemTotal = (basePrice + variantPrice) * quantity;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['variantName'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '${currencyFormat.format(basePrice + variantPrice)} × ${quantity}개',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            currencyFormat.format(itemTotal),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),

            const Divider(height: 32),
            _buildPriceRow('총 상품 금액', currencyFormat.format(subtotal)),
            const SizedBox(height: 8),
            _buildPriceRow('배송비', currencyFormat.format(currentShippingFee)),
            const Divider(height: 24),
            _buildPriceRow(
              '최종 결제 금액',
              currencyFormat.format(totalAmount),
              isTotal: true,
            ),

            if (subtotal >= freeShippingThreshold) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_shipping,
                      color: Colors.green.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '무료배송 혜택 적용',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 가격 행 위젯
  Widget _buildPriceRow(String title, String price, {bool isTotal = false}) {
    final style = TextStyle(
      fontSize: isTotal ? 16 : 14,
      fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: style),
        Text(
          price,
          style: style.copyWith(color: isTotal ? Colors.red.shade600 : null),
        ),
      ],
    );
  }
}
