// nanum_admin/lib/features/order_management/view/order_management_screen.dart (전체파일)

import 'package:file_picker/file_picker.dart';
import 'package:web/web.dart' as web;
import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/main_layout.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/order_cancellation_model.dart';
import '../../../data/repositories/order_repository.dart';
import '../viewmodel/order_viewmodel.dart';

import 'dart:js_interop';
import 'dart:typed_data';

class OrderManagementScreen extends ConsumerStatefulWidget {
  final OrderType orderType;
  const OrderManagementScreen({super.key, required this.orderType});

  @override
  ConsumerState<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends ConsumerState<OrderManagementScreen> {
  String _adminNote = '';

  // 엑셀 내보내기 함수
  void _exportToExcel(List<Order> orders) {
    final excel = Excel.createExcel();
    final Sheet sheet = excel[excel.getDefaultSheet()!];

    // Header 추가
    sheet.appendRow(
      [
        '주문번호',
        '상품명',
        '수량',
        '구매자',
        '연락처',
        '주소',
        if (widget.orderType == OrderType.groupBuy) '송장번호',
      ].map((e) => TextCellValue(e)).toList(),
    );

    // Data 추가
    for (final order in orders) {
      sheet.appendRow([
        TextCellValue(order.participantId.toString()),
        TextCellValue(order.productName),
        IntCellValue(order.quantity),
        TextCellValue(order.userName ?? ''),
        TextCellValue(order.userPhone ?? ''),
        TextCellValue(order.deliveryAddress),
      ]);
    }

    final bytes = excel.save();
    if (bytes != null) {
      final blob = web.Blob(
        [Uint8List.fromList(bytes).toJS].toJS,
        web.BlobPropertyBag(
            type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'),
      );
      final url = web.URL.createObjectURL(blob);
      final anchor = web.HTMLAnchorElement()
        ..href = url
        ..style.display = 'none'
        ..download =
            'orders_${widget.orderType.name}_${DateTime.now().toIso8601String().substring(0, 10)}.xlsx';

      web.document.body?.append(anchor);
      anchor.click();

      web.URL.revokeObjectURL(url);
      anchor.remove();
    }
  }

  // 파일 선택 및 업로드 함수
  void _pickAndUploadExcel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      await ref
          .read(orderViewModelProvider(widget.orderType).notifier)
          .uploadAndProcessExcel(result.files.single.bytes!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(orderViewModelProvider(widget.orderType));
    final title = widget.orderType == OrderType.shop ? '쇼핑몰 주문내역' : '공동구매 주문내역';

    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                ordersAsync.when(
                  data: (orders) => Row(
                    children: [
                      if (widget.orderType == OrderType.groupBuy) ...[
                        ElevatedButton.icon(
                          icon: const Icon(Icons.upload),
                          label: const Text('송장 일괄 업로드'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange),
                          onPressed: ordersAsync.isLoading
                              ? null
                              : () => _pickAndUploadExcel(),
                        ),
                        const SizedBox(width: 16),
                      ],
                      ElevatedButton.icon(
                        icon: const Icon(Icons.download),
                        label: const Text('엑셀로 내보내기'),
                        onPressed:
                            orders.isEmpty ? null : () => _exportToExcel(orders),
                      ),
                    ],
                  ),
                  loading: () => const SizedBox(),
                  error: (e, s) => const SizedBox(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ordersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Text('Error: $e'),
                data: (orders) => _buildOrderList(orders),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders) {
  if (orders.isEmpty) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('주문이 없습니다', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  return FutureBuilder<Map<int, Map<String, dynamic>>>(
    future: ref.read(orderRepositoryProvider).fetchOrdersWithCancellations(),
    builder: (context, orderSnapshot) {
      final orderData = orderSnapshot.data ?? {};

      Map<int, List<Order>> groupedOrders = {};
      Map<int, Map<String, dynamic>> orderInfo = {};
      
      for (final order in orders) {
        final actualOrderId = order.orderId ?? order.participantId;
        
        if (!groupedOrders.containsKey(actualOrderId)) {
          groupedOrders[actualOrderId] = [];
          
          final data = orderData[actualOrderId];
          final cancellation = data?['cancellation'] as OrderCancellation?;
          
          String displayStatus;
          if (cancellation != null) {
            switch (cancellation.status) {
              case 'pending':
                displayStatus = 'cancel_requested';
                break;
              case 'approved':
                displayStatus = 'cancelled';
                break;
              case 'rejected':
                displayStatus = 'cancel_rejected';
                break;
              default:
                displayStatus = data?['order_status'] ?? 'confirmed';
            }
          } else {
            displayStatus = data?['order_status'] ?? 'confirmed';
          }
          
          orderInfo[actualOrderId] = {
            'recipient_name': data?['recipient_name'] ?? order.userName,
            'recipient_phone': data?['recipient_phone'] ?? order.userPhone,
            'shipping_address': data?['shipping_address'] ?? order.deliveryAddress,
            'status': displayStatus,
            'total_amount': data?['total_amount'] ?? 0,
            'cancellation': cancellation,
          };
        }
        groupedOrders[actualOrderId]!.add(order);
      }

      return Column(
        children: [
          // 테이블 헤더
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text('주문번호', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('고객정보', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('상태', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: Text('상품수', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('총액', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('액션', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          
          // 테이블 데이터
          Expanded(
            child: ListView.builder(
              itemCount: groupedOrders.length,
              itemBuilder: (context, index) {
                final orderId = groupedOrders.keys.elementAt(index);
                final orderItems = groupedOrders[orderId]!;
                final info = orderInfo[orderId]!;
                
                return _buildTableRow(orderId, orderItems, info);
              },
            ),
          ),
        ],
      );
    },
  );
}

Widget _buildTableRow(int orderId, List<Order> items, Map<String, dynamic> info) {
  final status = info['status'] as String? ?? 'confirmed';
  final totalAmount = (info['total_amount'] as num?)?.toInt() ?? 0;
  final cancellation = info['cancellation'] as OrderCancellation?;

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(color: Colors.grey[300]!),
        left: BorderSide(color: Colors.grey[300]!),
        right: BorderSide(color: Colors.grey[300]!),
      ),
      color: status == 'cancel_requested' ? Colors.orange[50] : Colors.white,
    ),
    child: Row(
      children: [
        // 주문번호 + 상품보기 버튼
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ORD-$orderId', style: TextStyle(fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () => _showOrderDetails(orderId, items, info),
                child: Text('상품보기 (${items.length}개)', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
        
        // 고객정보
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${info['recipient_name'] ?? '정보없음'}'),
              Text('${info['recipient_phone'] ?? '연락처없음'}', 
                   style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ),
        
        // 상태 + 취소요청 정보
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusChip(status),
              if (cancellation != null) ...[
                SizedBox(height: 4),
                Text('${cancellation.cancelReason}', 
                     style: TextStyle(fontSize: 11, color: Colors.orange[700])),
              ],
            ],
          ),
        ),
        
        // 상품 개수
        Expanded(
          flex: 1,
          child: Text('${items.length}개'),
        ),
        
        // 총액
        Expanded(
          flex: 2,
          child: Text('${totalAmount.toString()}원', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        
        // 액션 버튼
        Expanded(
          flex: 2,
          child: _buildActionButtons(status, cancellation),
        ),
      ],
    ),
  );
}

void _showOrderDetails(int orderId, List<Order> items, Map<String, dynamic> info) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('주문 상세: ORD-$orderId'),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('배송지: ${info['shipping_address'] ?? '주소없음'}'),
            SizedBox(height: 16),
            Text('주문 상품:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            ...items.map((item) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(child: Text(item.productName)),
                  Text('수량: ${item.quantity}'),
                ],
              ),
            )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('닫기'),
        ),
      ],
    ),
  );
}


  Color _getStatusColor(String status) {
  switch (status) {
    case 'cancel_requested': return Colors.orange;
    case 'cancelled': return Colors.red;
    case 'cancel_rejected': return Colors.purple; // ⭐️ 새로운 색상
    case 'confirmed': return Colors.blue;
    case 'processing': return Colors.purple;
    case 'shipped': return Colors.green;
    default: return Colors.grey;
  }
}

String _getStatusLabel(String status) {
  switch (status) {
    case 'cancelled': return '취소됨';
    case 'cancel_rejected': return '취소 거부됨'; // ⭐️ 새로운 라벨
    case 'confirmed': return '확인됨';
    case 'processing': return '처리중';
    case 'shipped': return '배송중';
    case 'cancel_requested': return '취소요청';
    default: return status;
  }
}

  Widget _buildStatusChip(String status) {
    Color color = _getStatusColor(status);
    String label = _getStatusLabel(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  Widget _buildOrderCard(int orderId, List<Order> items, Map<String, dynamic> info) {
    final status = info['status'] as String;
    final totalAmount = info['total_amount'] as int;
    final cancellation = info['cancellation'] as OrderCancellation?;

    // 디버깅 추가
  debugPrint('🔍 Building card for order $orderId:');
  debugPrint('  - status: $status');
  debugPrint('  - cancellation: ${cancellation != null ? 'exists' : 'null'}');
  if (cancellation != null) {
    debugPrint('  - cancellation.status: ${cancellation.status}');
    debugPrint('  - cancellation.cancelReason: ${cancellation.cancelReason}');
  }
  
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '주문번호: ORD-$orderId',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '고객: ${info['recipient_name']} (${info['recipient_phone']})',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    _buildStatusChip(status),
                  ],
                ),
                
                const SizedBox(height: 8),
                Text(
                  '배송지: ${info['shipping_address']}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                
                // 취소 요청 정보 표시
                if (cancellation != null) ...[
  const SizedBox(height: 12),
  Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: _getCancellationBackgroundColor(cancellation.status),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: _getCancellationBorderColor(cancellation.status)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              _getCancellationIcon(cancellation.status), 
              color: _getCancellationIconColor(cancellation.status), 
              size: 20
            ),
            const SizedBox(width: 8),
            Text(
              _getCancellationTitle(cancellation.status),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getCancellationIconColor(cancellation.status),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('사유: ${cancellation.cancelReason}'),
        if (cancellation.cancelDetail != null)
          Text('상세: ${cancellation.cancelDetail}'),
        Text(
          '요청일: ${cancellation.requestedAt.toString().substring(0, 19)}',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        // ⭐️ 처리 완료된 경우 관리자 정보 표시
        if (cancellation.status != 'pending') ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '처리 결과: ${cancellation.status == 'approved' ? '승인됨' : '거부됨'}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (cancellation.adminNote != null && cancellation.adminNote!.isNotEmpty)
                  Text('관리자 메모: ${cancellation.adminNote}'),
                if (cancellation.processedAt != null)
                  Text(
                    '처리일: ${cancellation.processedAt!.toString().substring(0, 19)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ],
    ),
  ),

],
                
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '총 ${items.length}개 상품 • 총액: ${totalAmount.toString()}원',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    _buildActionButtons(status, cancellation),
                  ],
                ),
              ],
            ),
          ),
          
          // 상품 목록
          ExpansionTile(
            title: Text('상품 목록 (${items.length}개)'),
            initiallyExpanded: false,
            children: items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Expanded(child: Text(item.productName)),
                  Text('수량: ${item.quantity}', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Color _getCancellationBackgroundColor(String status) {
  switch (status) {
    case 'pending': return Colors.orange[50]!;
    case 'approved': return Colors.red[50]!;
    case 'rejected': return Colors.purple[50]!;
    default: return Colors.grey[50]!;
  }
}

Color _getCancellationBorderColor(String status) {
  switch (status) {
    case 'pending': return Colors.orange[200]!;
    case 'approved': return Colors.red[200]!;
    case 'rejected': return Colors.purple[200]!;
    default: return Colors.grey[200]!;
  }
}

Color _getCancellationIconColor(String status) {
  switch (status) {
    case 'pending': return Colors.orange[700]!;
    case 'approved': return Colors.red[700]!;
    case 'rejected': return Colors.purple[700]!;
    default: return Colors.grey[700]!;
  }
}

IconData _getCancellationIcon(String status) {
  switch (status) {
    case 'pending': return Icons.warning_amber;
    case 'approved': return Icons.cancel;
    case 'rejected': return Icons.block;
    default: return Icons.info;
  }
}

String _getCancellationTitle(String status) {
  switch (status) {
    case 'pending': return '취소 요청';
    case 'approved': return '취소 승인됨';
    case 'rejected': return '취소 거부됨';
    default: return '취소 관련';
  }
}

  Widget _buildActionButtons(String status, OrderCancellation? cancellation) {
    if (status == 'cancel_requested' && cancellation != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            onPressed: () => _handleCancelApproval(cancellation, false),
            icon: const Icon(Icons.close, size: 16),
            label: const Text('거부'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => _handleCancelApproval(cancellation, true),
            icon: const Icon(Icons.check, size: 16),
            label: const Text('승인'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      );
    }
    
    return Text(_getStatusLabel(status), style: TextStyle(color: Colors.grey[600]));
  }

  void _handleCancelApproval(OrderCancellation cancellation, bool approve) async {
    final action = approve ? '승인' : '거부';
    
    // 관리자 메모 입력 다이얼로그
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('취소 $action'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('주문번호: ORD-${cancellation.orderId}'),
            Text('취소 사유: ${cancellation.cancelReason}'),
            const SizedBox(height: 16),
            const Text('관리자 메모:'),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: '$action 사유를 입력해주세요',
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) => _adminNote = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(_adminNote),
            style: ElevatedButton.styleFrom(
              backgroundColor: approve ? Colors.orange : Colors.red,
            ),
            child: Text(action),
          ),
        ],
      ),
    );
    
    if (result != null) {
      try {
        if (approve) {
          await ref.read(orderRepositoryProvider)
              .approveCancellation(cancellation.id, result);
        } else {
          await ref.read(orderRepositoryProvider)
              .rejectCancellation(cancellation.id, result);
        }
        
        // 목록 새로고침
        ref.read(orderViewModelProvider(widget.orderType).notifier).fetchOrders();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('취소 요청이 $action되었습니다.'),
              backgroundColor: approve ? Colors.orange : Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('오류: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}