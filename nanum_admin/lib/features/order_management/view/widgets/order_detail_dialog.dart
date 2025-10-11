import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/order_model.dart';
import '../../viewmodel/order_viewmodel.dart';

class OrderDetailDialog extends ConsumerStatefulWidget {
  final OrderModel order;

  const OrderDetailDialog({
    super.key,
    required this.order,
  });

  @override
  ConsumerState<OrderDetailDialog> createState() => _OrderDetailDialogState();
}

class _OrderDetailDialogState extends ConsumerState<OrderDetailDialog> {
  final _trackingNumberController = TextEditingController();
  final _courierCompanyController = TextEditingController(); // ✅ 추가
  bool _isEditingTracking = false;

  @override
  void initState() {
    super.initState();
    // ✅ 기존 송장번호 로드
    _trackingNumberController.text = widget.order.trackingNumber ?? '';
    _courierCompanyController.text = widget.order.courierCompany ?? '';
  }

  @override
  void dispose() {
    _trackingNumberController.dispose();
    _courierCompanyController.dispose(); // ✅ 추가
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,###');

    return Dialog(
      child: Container(
        width: 800,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '주문 상세',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          widget.order.orderId,
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 16),
                          tooltip: '주문번호 복사',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: widget.order.orderId));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('주문번호가 복사되었습니다')),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    Chip(
                      label: Text(
                        widget.order.status.displayName,
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: widget.order.status.color,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 32),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 주문 정보
                    _buildSection(
                      title: '주문 정보',
                      icon: Icons.shopping_cart,
                      child: Column(
                        children: [
                          _buildInfoRow('주문일시', widget.order.formattedOrderDate),
                          _buildInfoRow('주문유형', widget.order.orderType == 'shop' ? '쇼핑몰' : '공동구매'),
                          _buildInfoRow(
                            '결제금액',
                            '₩${currencyFormat.format(widget.order.totalAmount)}',
                            valueStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 주문자 정보
                    _buildSection(
                      title: '주문자 정보',
                      icon: Icons.person,
                      child: Column(
                        children: [
                          _buildInfoRow('주문자명', widget.order.userName),
                          _buildInfoRow('이메일', widget.order.userEmail),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 배송 정보
                    _buildSection(
                      title: '배송 정보',
                      icon: Icons.local_shipping,
                      child: Column(
                        children: [
                          _buildInfoRow('받는 사람', widget.order.recipientName),
                          _buildInfoRow('연락처', widget.order.recipientPhone),
                          _buildInfoRow('배송주소', widget.order.shippingAddress),
                          const Divider(height: 24),
                          _buildTrackingNumberField(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 주문 상품
                    _buildSection(
                      title: '주문 상품',
                      icon: Icons.inventory_2,
                      child: Column(
                        children: widget.order.items.map((item) {
                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey[200]!),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.productName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '수량: ${item.quantity}개',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '₩${currencyFormat.format(item.price * item.quantity)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 32),

            // 하단 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.order.status == OrderStatus.confirmed)
                  ElevatedButton.icon(
                    onPressed: () {
                      _updateOrderStatus(OrderStatus.preparing);
                    },
                    icon: const Icon(Icons.inventory),
                    label: const Text('상품준비중으로 변경'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                if (widget.order.status == OrderStatus.preparing)
                  ElevatedButton.icon(
                    onPressed: _trackingNumberController.text.isNotEmpty
                        ? () => _updateOrderStatus(OrderStatus.shipping)
                        : null,
                    icon: const Icon(Icons.local_shipping),
                    label: const Text('배송중으로 변경'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                if (widget.order.status == OrderStatus.shipping)
                  ElevatedButton.icon(
                    onPressed: () {
                      _updateOrderStatus(OrderStatus.delivered);
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('배송완료로 변경'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: valueStyle ?? const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingNumberField() {
    return Column(
      children: [
        // 택배사
        Row(
          children: [
            SizedBox(
              width: 100,
              child: Text(
                '택배사',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              child: _isEditingTracking
                  ? DropdownButtonFormField<String>(
                      value: _courierCompanyController.text.isEmpty 
                          ? null 
                          : _courierCompanyController.text,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      hint: const Text('택배사 선택'),
                      items: const [
                        DropdownMenuItem(value: 'CJ대한통운', child: Text('CJ대한통운')),
                        DropdownMenuItem(value: '우체국택배', child: Text('우체국택배')),
                        DropdownMenuItem(value: '한진택배', child: Text('한진택배')),
                        DropdownMenuItem(value: '로젠택배', child: Text('로젠택배')),
                        DropdownMenuItem(value: 'GS25편의점택배', child: Text('GS25편의점택배')),
                        DropdownMenuItem(value: '쿠팡로켓배송', child: Text('쿠팡로켓배송')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          _courierCompanyController.text = value;
                        }
                      },
                    )
                  : Text(
                      _courierCompanyController.text.isEmpty
                          ? '등록되지 않음'
                          : _courierCompanyController.text,
                      style: TextStyle(
                        fontSize: 14,
                        color: _courierCompanyController.text.isEmpty
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // 송장번호
        Row(
          children: [
            SizedBox(
              width: 100,
              child: Text(
                '송장번호',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              child: _isEditingTracking
                  ? Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _trackingNumberController,
                            decoration: const InputDecoration(
                              hintText: '송장번호를 입력하세요',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          tooltip: '저장',
                          onPressed: _saveTrackingNumber, // ✅ 저장 로직
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          tooltip: '취소',
                          onPressed: () {
                            setState(() {
                              _isEditingTracking = false;
                              _trackingNumberController.text = widget.order.trackingNumber ?? '';
                              _courierCompanyController.text = widget.order.courierCompany ?? '';
                            });
                          },
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Text(
                          _trackingNumberController.text.isEmpty
                              ? '등록되지 않음'
                              : _trackingNumberController.text,
                          style: TextStyle(
                            fontSize: 14,
                            color: _trackingNumberController.text.isEmpty
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () {
                            setState(() => _isEditingTracking = true);
                          },
                          icon: Icon(
                            _trackingNumberController.text.isEmpty ? Icons.add : Icons.edit,
                            size: 16,
                          ),
                          label: Text(
                            _trackingNumberController.text.isEmpty ? '등록' : '수정',
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ],
    );
  }

  // ✅ 송장번호 저장 메서드 추가
  Future<void> _saveTrackingNumber() async {
    if (_trackingNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('송장번호를 입력해주세요'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await ref.read(orderViewModelProvider.notifier).updateTrackingNumber(
        orderId: widget.order.orderId,
        trackingNumber: _trackingNumberController.text,
        courierCompany: _courierCompanyController.text.isEmpty 
            ? null 
            : _courierCompanyController.text,
      );

      setState(() => _isEditingTracking = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ 송장번호가 등록되었습니다. 주문 상태가 "배송중"으로 변경되었습니다.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('송장번호 등록 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  // ✅ _updateOrderStatus 메서드에서 배송중 변경 시 송장번호 체크 추가
  Future<void> _updateOrderStatus(OrderStatus newStatus) async {
    // 배송중으로 변경 시 송장번호 필수
    if (newStatus == OrderStatus.shipping && _trackingNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('배송중으로 변경하려면 송장번호를 먼저 등록해주세요'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await ref.read(orderViewModelProvider.notifier).updateOrderStatus(
            widget.order.orderId,
            newStatus,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('주문 상태가 "${newStatus.displayName}"(으)로 변경되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('상태 변경 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

}