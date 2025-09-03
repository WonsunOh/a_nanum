// user_app/lib/features/payment/view/portone_web_html_screen.dart (전체 교체)
import 'package:flutter/material.dart';

class PortOneWebHtmlScreen extends StatefulWidget {
  final int totalAmount;
  final String orderName;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String customerAddress;

  const PortOneWebHtmlScreen({
    super.key,
    required this.totalAmount,
    required this.orderName,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.customerAddress,
  });

  @override
  State<PortOneWebHtmlScreen> createState() => _PortOneWebHtmlScreenState();
}

class _PortOneWebHtmlScreenState extends State<PortOneWebHtmlScreen> {
  bool _isLoading = false;

  void _requestPayment() {
    print('🔍 [DEBUG] 결제하기 버튼 클릭됨');
    
    if (_isLoading) {
      print('🔍 [DEBUG] 이미 처리 중이므로 무시');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    print('🔍 [DEBUG] 로딩 상태로 변경됨');
    
    _processPayment();
  }

  Future<void> _processPayment() async {
    try {
      print('🔍 [DEBUG] 결제 처리 시작');
      
      final merchantUid = 'order_${DateTime.now().millisecondsSinceEpoch}';
      print('🔍 [DEBUG] Merchant UID: $merchantUid');
      
      // 2초 대기로 결제 처리 시뮬레이션
      await Future.delayed(const Duration(seconds: 2));
      
      final result = {
        'success': true,
        'paymentId': merchantUid,
        'txId': 'test_${DateTime.now().millisecondsSinceEpoch}',
        'amount': widget.totalAmount,
        'message': 'PortOne 테스트 결제가 완료되었습니다.'
      };

      print('🔍 [DEBUG] 결제 완료, 결과: $result');

      if (mounted) {
        print('🔍 [DEBUG] 화면이 마운트된 상태, Navigator.pop 호출');
        Navigator.pop(context, result);
      } else {
        print('⚠️ [DEBUG] 화면이 마운트되지 않은 상태');
      }
      
    } catch (e, stackTrace) {
      print('❌ [DEBUG] 결제 처리 에러: $e');
      print('❌ [DEBUG] 스택트레이스: $stackTrace');
      
      if (mounted) {
        Navigator.pop(context, {
          'success': false,
          'error': '결제 처리 중 오류가 발생했습니다: $e'
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        print('🔍 [DEBUG] 로딩 상태 해제');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🔍 [DEBUG] PortOneWebHtmlScreen build 호출, _isLoading: $_isLoading');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('PortOne 결제'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _isLoading 
              ? null 
              : () {
                  print('🔍 [DEBUG] 취소 버튼 클릭');
                  Navigator.pop(context, {'success': false, 'cancelled': true});
                },
        ),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.payment,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 32),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PortOne 결제',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    _buildInfoRow('상품명', widget.orderName),
                    _buildInfoRow('주문자', widget.customerName),
                    _buildInfoRow('연락처', widget.customerPhone),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '결제 금액',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_formatAmount(widget.totalAmount)}원',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            if (_isLoading) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('PortOne 결제 처리 중...'),
              const SizedBox(height: 16),
              Text('잠시만 기다려주세요', style: TextStyle(color: Colors.grey[600])),
            ] else ...[
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    print('🔍 [DEBUG] ElevatedButton onPressed 호출됨');
                    _requestPayment();
                  },
                  icon: const Icon(Icons.credit_card),
                  label: Text('${_formatAmount(widget.totalAmount)}원 결제하기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    print('🔍 [DEBUG] 취소 버튼 클릭됨');
                    Navigator.pop(context, {'success': false, 'cancelled': true});
                  },
                  child: const Text('취소'),
                ),
              ),
            ],
            
            const SizedBox(height: 32),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '웹 환경에서 PortOne 결제 테스트가 진행됩니다.',
                      style: TextStyle(color: Colors.blue[700]),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}