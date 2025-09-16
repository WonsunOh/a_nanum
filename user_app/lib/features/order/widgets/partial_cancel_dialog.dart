// user_app/lib/features/order/widgets/partial_cancel_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/models/order_item_model.dart';
import '../viewmodel/partial_cancel_viewmodel.dart';

class PartialCancelDialog extends ConsumerStatefulWidget {
  final OrderItemModel orderItem;

  const PartialCancelDialog({
    super.key,
    required this.orderItem,
  });

  @override
  ConsumerState<PartialCancelDialog> createState() => _PartialCancelDialogState();
}

class _PartialCancelDialogState extends ConsumerState<PartialCancelDialog> {
  final _reasonController = TextEditingController();
  final _detailController = TextEditingController();
  int _cancelQuantity = 1;
  String _selectedReason = '단순 변심';

  final List<String> _cancelReasons = [
    '단순 변심',
    '상품 불량',
    '배송 지연',
    '잘못된 상품 주문',
    '기타',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cancelState = ref.watch(partialCancelViewModelProvider);
    final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '');

    return AlertDialog(
      title: const Text('부분 취소 요청'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상품 정보
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: widget.orderItem.productImageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              widget.orderItem.productImageUrl!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.image),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.orderItem.productName ?? '상품명',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${currencyFormat.format(widget.orderItem.pricePerItem)}원 × ${widget.orderItem.quantity}개',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 취소 수량 선택
            const Text('취소 수량', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: _cancelQuantity > 1
                      ? () => setState(() => _cancelQuantity--)
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('$_cancelQuantity'),
                ),
                IconButton(
                  onPressed: _cancelQuantity < widget.orderItem.quantity
                      ? () => setState(() => _cancelQuantity++)
                      : null,
                  icon: const Icon(Icons.add),
                ),
                const SizedBox(width: 8),
                Text('/ ${widget.orderItem.quantity}개'),
              ],
            ),

            const SizedBox(height: 16),

            // 환불 금액 표시
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('환불 예정 금액'),
                  Text(
                    '${currencyFormat.format(widget.orderItem.pricePerItem * _cancelQuantity)}원',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 취소 사유 선택
            const Text('취소 사유', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedReason,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: _cancelReasons.map((reason) {
                return DropdownMenuItem(
                  value: reason,
                  child: Text(reason),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedReason = value!);
              },
            ),

            const SizedBox(height: 16),

            // 상세 사유 입력
            const Text('상세 사유 (선택)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _detailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: '취소 사유를 자세히 입력해주세요',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: cancelState.isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: cancelState.isLoading ? null : _submitCancellation,
          child: cancelState.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('취소 요청'),
        ),
      ],
    );
  }

  Future<void> _submitCancellation() async {
    final success = await ref.read(partialCancelViewModelProvider.notifier)
        .requestPartialCancellation(
      orderItemId: widget.orderItem.id,
      cancelReason: _selectedReason,
      cancelDetail: _detailController.text.trim().isEmpty 
          ? null 
          : _detailController.text.trim(),
      cancelQuantity: _cancelQuantity,
    );

    if (success && mounted) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('부분 취소 요청이 완료되었습니다.'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      final errorMessage = ref.read(partialCancelViewModelProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage ?? '취소 요청에 실패했습니다.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}