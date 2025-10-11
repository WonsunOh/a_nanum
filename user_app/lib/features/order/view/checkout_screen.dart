// user_app/lib/features/order/view/checkout_screen.dart (전체 교체)

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/cart_item_model.dart';
import '../../../data/repositories/profile_repository.dart';
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
  
  final _recipientNameController = TextEditingController();
  final _recipientPhoneController = TextEditingController();
  final _postcodeController = TextEditingController();
  final _addressController = TextEditingController();
  final _detailAddressController = TextEditingController();
  final _deliveryRequestController = TextEditingController();

  bool _sameAsOrderer = false;
  String _ordererName = '';
  String _ordererPhone = '';

  bool _isAutoFilled = false;
  bool _isEditMode = false;

  Map<String, dynamic>? directPurchaseData;
  bool get isDirectPurchase => directPurchaseData != null;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDirectPurchaseMode();
      
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _loadOrdererAndRecipientInfo();
        }
      });
    });
  }

  @override
  void dispose() {
    _recipientNameController.dispose();
    _recipientPhoneController.dispose();
    _postcodeController.dispose();
    _addressController.dispose();
    _detailAddressController.dispose();
    _deliveryRequestController.dispose();
    super.dispose();
  }

  void _loadOrdererAndRecipientInfo() {
    final userProfileAsync = ref.read(userProvider);
    
    userProfileAsync.when(
      data: (userProfile) {
        if (userProfile != null && mounted) {
          setState(() {
            _ordererName = userProfile.fullName ?? userProfile.nickname ?? '사용자';
            _ordererPhone = userProfile.phoneNumber ?? '';
            
            if (_sameAsOrderer && userProfile.level >= 2) {
              _fillRecipientWithOrdererInfo(userProfile);
            }
          });
        }
      },
      loading: () {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _loadOrdererAndRecipientInfo();
          }
        });
      },
      error: (error, stackTrace) {
        print('사용자 프로필 로드 에러: $error');
      },
    );
  }

  void _fillRecipientWithOrdererInfo(dynamic userProfile) {
    _recipientNameController.text = userProfile.fullName ?? userProfile.nickname ?? '';
    _recipientPhoneController.text = userProfile.phoneNumber ?? '';
    
    if (userProfile.postcode != null && userProfile.postcode!.isNotEmpty) {
      _postcodeController.text = userProfile.postcode!;
    }
    
    if (userProfile.address != null && userProfile.address!.isNotEmpty) {
      _addressController.text = userProfile.address!;
    }
    
    if (userProfile.detailAddress != null && userProfile.detailAddress!.isNotEmpty) {
      _detailAddressController.text = userProfile.detailAddress!;
    }
    
    _isAutoFilled = true;
  }

  void _toggleSameAsOrderer(bool? value) {
    setState(() {
      _sameAsOrderer = value ?? false;
      
      if (_sameAsOrderer) {
        final userProfileAsync = ref.read(userProvider);
        userProfileAsync.whenData((profile) {
          if (profile != null && profile.level >= 2) {
            _fillRecipientWithOrdererInfo(profile);
          } else if (profile != null) {
            _recipientNameController.text = profile.fullName ?? profile.nickname ?? '';
            _recipientPhoneController.text = profile.phoneNumber ?? '';
          }
        });
      } else {
        _recipientNameController.clear();
        _recipientPhoneController.clear();
        _postcodeController.clear();
        _addressController.clear();
        _detailAddressController.clear();
        _isAutoFilled = false;
      }
      _isEditMode = !_sameAsOrderer;
    });
  }

  void _checkDirectPurchaseMode() {
    final directData = ref.read(directPurchaseProvider);
    
    if (directData != null) {
      directPurchaseData = directData.toJson();
      
      if (mounted) setState(() {});

      final items = directPurchaseData!['items'] as List?;
      if (items == null || items.isEmpty) {
        context.go('/shop/cart');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('주문할 상품이 없습니다.')),
        );
      } else {
        ref.read(directPurchaseProvider.notifier).state = null;
      }
    }
  }

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

  String get _fullAddress {
    final postcode = _postcodeController.text;
    final address = _addressController.text;
    final detailAddress = _detailAddressController.text;

    return '($postcode) $address $detailAddress'.trim();
  }

  int _calculateDirectPurchaseSubtotal() {
    if (directPurchaseData == null) return 0;
    final basePrice =
        directPurchaseData!['productDiscountPrice'] ??
        directPurchaseData!['productPrice'];
    final items = directPurchaseData!['items'] as List;

    return items.fold<int>(0, (sum, item) {
      final variantPrice = item['additionalPrice'] ?? 0;
      final quantity = item['quantity'];
      final num itemSubtotal = (basePrice + variantPrice) * quantity;
      return sum + itemSubtotal.toInt();
    });
  }

  int _calculateCartSubtotal(List<CartItemModel> items) {
    return items.fold(0, (sum, item) {
      final basePrice = item.product?.discountPrice ?? item.product?.price ?? 0;
      final variantPrice = item.variantAdditionalPrice ?? 0;
      final finalPrice = basePrice + variantPrice;
      return sum + (finalPrice * item.quantity);
    });
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    List<dynamic> orderItems;
    int subtotal;

    if (isDirectPurchase) {
      orderItems = directPurchaseData!['items'];
      subtotal = _calculateDirectPurchaseSubtotal();
      
      if (orderItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('주문할 상품 정보가 없습니다.')),
        );
        return;
      }
    } else {
      final cartState = ref.read(cartViewModelProvider).valueOrNull;
      if (cartState == null || cartState.selectedItemIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('주문할 상품을 선택해주세요.')),
        );
        return;
      }
      
      final cartItems = cartState.items
          .where((item) => cartState.selectedItemIds.contains(item.id))
          .cast<CartItemModel>()
          .toList();
      
      orderItems = cartItems;
      subtotal = _calculateCartSubtotal(cartItems);
    }

    const int shippingFee = 3000;
    const int freeShippingThreshold = 50000;
    final int currentShippingFee = (subtotal >= freeShippingThreshold) ? 0 : shippingFee;
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
                  color: Colors.black.withOpacity(0.1),
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
                        ],
                        Text(
                          isDirectPurchase ? '바로결제' : '결제하기',
                          style: const TextStyle(
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

  Widget _buildNarrowLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildOrdererInfoSection(),
          const SizedBox(height: 8),
          _buildShippingForm(),
          const SizedBox(height: 8),
          _buildOrderSummary(),
        ],
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildOrdererInfoSection(),
                const SizedBox(height: 8),
                _buildShippingForm(),
              ],
            ),
          ),
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

  Widget _buildOrdererInfoSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.person, color: Colors.blue.shade600),
                ),
                const SizedBox(width: 12),
                const Text(
                  '주문자 정보',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                const SizedBox(
                  width: 80,
                  child: Text('이름', style: TextStyle(
                    fontWeight: FontWeight.w500, color: Colors.grey,
                  )),
                ),
                Text(_ordererName.isNotEmpty ? _ordererName : '로딩중...'),
              ],
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                const SizedBox(
                  width: 80,
                  child: Text('연락처', style: TextStyle(
                    fontWeight: FontWeight.w500, color: Colors.grey,
                  )),
                ),
                Text(_ordererPhone.isNotEmpty ? _ordererPhone : '등록된 연락처 없음'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingForm() {
    final userProfileAsync = ref.watch(userProvider);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                  Expanded(
                    child: Column(
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
                  ),
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

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: _sameAsOrderer,
                      onChanged: _toggleSameAsOrderer,
                      activeColor: isDirectPurchase 
                          ? Colors.orange.shade600 
                          : Colors.blue.shade600,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        '주문자와 동일한 정보로 입력',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    if (_sameAsOrderer && _isAutoFilled)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '자동 입력됨',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              _buildTextField(
                controller: _recipientNameController,
                label: '받는 사람',
                hint: '받는 분의 성함을 입력하세요',
                icon: Icons.person_outline,
                readOnly: _sameAsOrderer && _isAutoFilled && !_isEditMode,
                validator: (v) => v!.isEmpty ? '받는 사람을 입력해주세요' : null,
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _recipientPhoneController,
                label: '연락처',
                hint: '010-1234-5678',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                readOnly: _sameAsOrderer && _isAutoFilled && !_isEditMode,
                validator: (v) => v!.isEmpty ? '연락처를 입력해주세요' : null,
              ),

              const SizedBox(height: 24),

              const Text(
                '배송 주소',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

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
                      onPressed: (_sameAsOrderer && !_isEditMode) ? null : _openAddressSearch,
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

              _buildTextField(
                controller: _addressController,
                label: '기본 주소',
                hint: '주소 검색을 통해 자동 입력됩니다',
                icon: Icons.location_on_outlined,
                readOnly: true,
                validator: (v) => v!.isEmpty ? '주소를 검색해주세요' : null,
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _detailAddressController,
                label: '상세 주소',
                hint: '동/호수를 입력하세요 (예: 101동 1201호)',
                icon: Icons.home_outlined,
                readOnly: _sameAsOrderer && _isAutoFilled && !_isEditMode,
                validator: (v) => v!.isEmpty ? '상세 주소를 입력해주세요' : null,
              ),

              const SizedBox(height: 24),

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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      keyboardType: keyboardType,
      readOnly: readOnly,
      validator: isRequired ? validator : null,
    );
  }

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
            _buildPaymentInfoRow('받는 분', _recipientNameController.text),
            _buildPaymentInfoRow('연락처', _recipientPhoneController.text),
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
                  const Expanded(
                    child: Text(
                      '테스트 환경으로 실제 결제는 발생하지 않습니다.',
                      style: TextStyle(color: Colors.amber),
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

  // 🔥🔥🔥 전체 수정: _processPayment에서 올바른 함수를 호출하도록 변경
  Future<void> _processPayment(
    List<dynamic> items,
    int totalAmount,
    int currentShippingFee,
  ) async {
    try {
      final userEmail = "${_recipientPhoneController.text}@temp.com";

      Map<String, dynamic>? paymentResult;

      paymentResult = await showDialog<Map<String, dynamic>>(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog.fullscreen(
          child: PortOneWebHtmlScreen(
            totalAmount: totalAmount,
            orderName: isDirectPurchase
                ? '바로구매 ${directPurchaseData?['productName'] ?? ''}'
                : '소분쇼핑몰 주문 ${items.length}건',
            customerName: _recipientNameController.text,
            customerPhone: _recipientPhoneController.text,
            customerEmail: userEmail,
            customerAddress: _addressController.text,
          ),
        ),
      );

      if (paymentResult != null && paymentResult['success'] == true) {
        bool orderSuccess = false;
        
        if (isDirectPurchase) {
          // 🔥🔥🔥 수정: 바로구매 전용 ViewModel 함수 호출
          orderSuccess = await _createDirectPurchaseOrder(
            totalAmount: totalAmount,
            currentShippingFee: currentShippingFee,
            paymentId: paymentResult['paymentId'],
          );
        } else {
          // 기존 장바구니 주문
          orderSuccess = await _createCartOrder(
            items: items.cast<CartItemModel>(),
            totalAmount: totalAmount,
            currentShippingFee: currentShippingFee,
            paymentId: paymentResult['paymentId'],
          );
        }

        if (mounted && orderSuccess) {
          await _checkAndUpgradeLevel();

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
    } catch (e) {
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

  Future<void> _checkAndUpgradeLevel() async {
    try {
      final userProfileAsync = ref.read(userProvider);
      await userProfileAsync.when(
        data: (userProfile) async {
          if (userProfile != null && userProfile.level == 1) {
            final profileRepository = ref.read(profileRepositoryProvider);
            
            final recipientName = _recipientNameController.text.trim();
            final recipientPhone = _recipientPhoneController.text.trim();
            final postcode = _postcodeController.text.trim();
            final address = _addressController.text.trim();
            final detailAddress = _detailAddressController.text.trim();
            
            await profileRepository.updateProfileAndLevel(
              fullName: recipientName.isNotEmpty ? recipientName : null,
              phoneNumber: recipientPhone.isNotEmpty ? recipientPhone : null,
              address: address.isNotEmpty ? address : null,
              detailAddress: detailAddress.isNotEmpty ? detailAddress : null,
              postcode: postcode.isNotEmpty ? postcode : null,
              newLevel: 2,
            );
            
            ref.invalidate(userProvider);
            
            if (mounted) {
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.celebration, color: Colors.white),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '🎉 레벨업 완료!',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text('레벨 1 → 레벨 2로 승급! 배송정보가 저장되었습니다.'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.purple,
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }
              });
            }
          }
        },
        loading: () async {
          await Future.delayed(const Duration(milliseconds: 500));
          await _checkAndUpgradeLevel();
        },
        error: (error, stackTrace) async {
          print('❌ 레벨업 체크 중 에러: $error');
        },
      );
    } catch (e) {
      print('❌ 자동 레벨업 처리 중 에러: $e');
    }
  }

  Future<bool> _createCartOrder({
    required List<CartItemModel> items,
    required int totalAmount,
    required int currentShippingFee,
    required String paymentId,
  }) async {
    try {
      final success = await ref.read(orderViewModelProvider.notifier).createOrder(
        cartItems: items,
        totalAmount: totalAmount,
        shippingFee: currentShippingFee,
        recipientName: _recipientNameController.text,
        recipientPhone: _recipientPhoneController.text,
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

  // 🔥🔥🔥 수정: 바로구매 전용 주문 생성 헬퍼 함수
  Future<bool> _createDirectPurchaseOrder({
    required int totalAmount,
    required int currentShippingFee,
    required String paymentId,
  }) async {
    if (directPurchaseData == null) {
      print('❌ 바로구매 데이터가 없습니다.');
      return false;
    }
    try {
      // 바로구매 데이터에서 필요한 정보 추출
      final productId = directPurchaseData!['productId'] as int;
      final items = directPurchaseData!['items'] as List;
      // 바로구매는 상품이 하나이므로, 첫번째 아이템의 수량을 대표로 사용
      final quantity = items.first['quantity'] as int? ?? 1;
      final productPrice = (directPurchaseData!['productDiscountPrice'] ?? directPurchaseData!['productPrice']) as int;

      // ViewModel 함수 호출
      final success = await ref.read(orderViewModelProvider.notifier).createDirectOrder(
        productId: productId,
        quantity: quantity,
        productPrice: productPrice,
        totalAmount: totalAmount,
        shippingFee: currentShippingFee,
        recipientName: _recipientNameController.text,
        recipientPhone: _recipientPhoneController.text,
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

  String _formatAmount(int amount) {
    return NumberFormat('#,###').format(amount);
  }

  Widget _buildOrderSummary() {
    if (isDirectPurchase && directPurchaseData != null) {
      return _buildDirectPurchaseOrderSummary();
    }

    final cartAsync = ref.watch(cartViewModelProvider);
    final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
            color: Colors.black.withOpacity(0.05),
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
                                  '${currencyFormat.format(basePrice + variantPrice)} × $quantity개',
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
