// user_app/lib/features/notifications/view/order_cancellation_rejected_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodel/notification_viewmodel.dart';

class OrderCancellationRejectedScreen extends ConsumerStatefulWidget {
  final int orderId;

  const OrderCancellationRejectedScreen({
    super.key,
    required this.orderId,
  });

  @override
  ConsumerState<OrderCancellationRejectedScreen> createState() =>
      _OrderCancellationRejectedScreenState();
}

class _OrderCancellationRejectedScreenState 
    extends ConsumerState<OrderCancellationRejectedScreen> {
  final _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resubmitAsync = ref.watch(cancellationResubmitProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('취소 요청 거부'),
        backgroundColor: Colors.red.shade50,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 거부 안내 카드
              _buildRejectedInfoCard(),
              const SizedBox(height: 24),

              // 주문 정보 섹션
              _buildOrderInfoSection(),
              const SizedBox(height: 24),

              // 재요청 섹션
              _buildResubmitSection(),
              const SizedBox(height: 32),

              // 재요청 버튼
              _buildResubmitButton(resubmitAsync),
              const SizedBox(height: 16),

              // 주문 상세 보기 버튼
              _buildOrderDetailButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// 거부 안내 카드
  Widget _buildRejectedInfoCard() {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.cancel, color: Colors.red.shade600, size: 24),
                const SizedBox(width: 8),
                Text(
                  '취소 요청이 거부되었습니다',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '주문 상태나 배송 진행 상황으로 인해 취소 요청이 거부되었습니다. '
              '다시 취소를 원하시면 아래에서 재요청하실 수 있습니다.',
              style: TextStyle(
                color: Colors.red.shade600,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 주문 정보 섹션
  Widget _buildOrderInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '주문 정보',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('주문번호', '#${widget.orderId}'),
              const SizedBox(height: 8),
              _buildInfoRow('주문상태', '배송준비중', valueColor: Colors.orange),
              const SizedBox(height: 8),
              _buildInfoRow('거부 사유', '이미 상품 준비가 완료되어 취소가 어렵습니다'),
            ],
          ),
        ),
      ],
    );
  }

  /// 정보 행 위젯
  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  /// 재요청 섹션
  Widget _buildResubmitSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '취소 재요청',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '취소가 필요한 구체적인 사유를 적어주세요. 관리자가 검토 후 처리해드립니다.',
          style: TextStyle(
            color: Colors.grey,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _reasonController,
          maxLines: 4,
          maxLength: 200,
          decoration: const InputDecoration(
            hintText: '예: 주소가 잘못되어 배송이 불가능합니다.\n예: 중복 주문으로 인한 취소 요청입니다.',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '취소 사유를 입력해주세요';
            }
            if (value.trim().length < 10) {
              return '취소 사유를 10자 이상 입력해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// 재요청 버튼
  Widget _buildResubmitButton(AsyncValue<void> resubmitAsync) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: resubmitAsync.isLoading ? null : _submitResubmitRequest,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: resubmitAsync.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                '취소 재요청',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  /// 주문 상세 보기 버튼
  Widget _buildOrderDetailButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: () => _navigateToOrderDetail(),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade400),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          '주문 상세 보기',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// 재요청 제출
  Future<void> _submitResubmitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final confirmed = await _showConfirmDialog();
    if (!confirmed) return;

    try {
      final success = await ref
          .read(cancellationResubmitProvider.notifier)
          .resubmitCancellation(widget.orderId, _reasonController.text.trim());

      if (success && mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    }
  }

  /// 확인 다이얼로그
  Future<bool> _showConfirmDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('취소 재요청'),
        content: const Text('취소 재요청을 제출하시겠습니까?\n관리자 검토 후 처리됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('제출'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// 성공 다이얼로그
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('재요청 완료'),
        content: const Text('취소 재요청이 성공적으로 제출되었습니다.\n관리자 검토 후 알림으로 결과를 안내드리겠습니다.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 다이얼로그 닫기
              context.pop(); // 현재 화면 닫기
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 에러 다이얼로그
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('재요청 실패'),
        content: Text('재요청 처리 중 오류가 발생했습니다.\n\n$message'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 주문 상세 화면으로 이동
  void _navigateToOrderDetail() {
    context.push('/orders/${widget.orderId}');
  }
}