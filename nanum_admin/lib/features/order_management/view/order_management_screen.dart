// nanum_admin/lib/features/order_management/view/order_management_screen.dart (전체파일)


import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:web/web.dart' as web;
import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/main_layout.dart';
import '../../../data/models/order_item_cancellation_model.dart';
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

  List<OrderItemCancellation> _partialCancellations = []; 

  // 검색 및 필터 상태 추가
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = '전체';
  String _searchQuery = '';
  
  final List<String> _statusOptions = [
    '전체', '결제완료', '상품준비중', '배송중', '배송완료', '교환반품'
  ];

  @override
  void initState() {
    super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _fetchPartialCancellations(); // ✅ 부분취소 데이터 조회
  });
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
            // 검색 및 필터 섹션
            _buildSearchAndFilter(),
            
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

  // 검색 및 필터 위젯
  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          // 검색바
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: '주문번호, 주문자명, 받는사람명, 전화번호로 검색',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = _searchController.text;
                  });
                },
                child: const Text('검색'),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 상태 필터 버튼들
          Wrap(
            spacing: 8,
            children: _statusOptions.map((status) {
              final isSelected = _selectedStatus == status;
              return FilterChip(
                label: Text(status),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedStatus = status;
                  });
                },
                backgroundColor: Colors.white,
                selectedColor: Colors.blue[100],
                checkmarkColor: Colors.blue[800],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

// 주문 표시용 번호 (기존 ORD- prefix 제거)
String _formatOrderNumber(int orderId) {
  // 실제로는 데이터베이스에 order_number 컬럼이 있다면 그것을 사용
  // 없다면 orderId를 기반으로 8자리 생성
  final seed = orderId * 13 + 91000000; // 시드값으로 일관된 번호 생성
  return seed.toString().substring(0, 8);
}


// 날짜별 그룹화된 주문 목록을 테이블로 표시
Widget _buildDateGroupedOrderList(
  Map<String, Map<int, List<Order>>> groupedByDate,
  Map<int, Map<String, dynamic>> orderInfo,
) {
  final sortedDates = groupedByDate.keys.toList()
    ..sort((a, b) => b.compareTo(a)); // 최신 날짜부터
  
  return ListView.builder(
    itemCount: sortedDates.length,
    itemBuilder: (context, index) {
      final dateKey = sortedDates[index];
      final dateOrders = groupedByDate[dateKey]!;
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 날짜 헤더
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(DateTime.parse(dateKey)),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${dateOrders.length}건',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[600],
                  ),
                ),
              ],
            ),
          ),
          
          // 테이블 헤더
          _buildTableHeader(),
          
          // 해당 날짜의 주문들을 테이블 행으로 표시
          ...dateOrders.entries.map((orderEntry) {
            final orderId = orderEntry.key;
            final items = orderEntry.value;
            final info = orderInfo[orderId]!;
            
            return _buildTableRow(orderId, items, info);
          }),
          
          const SizedBox(height: 16),
        ],
      );
    },
  );
}

// 테이블 헤더
Widget _buildTableHeader() {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      border: Border.all(color: Colors.grey[300]!),
    ),
    child: Row(
      children: [
        _buildHeaderCell('주문번호', flex: 2),
        _buildHeaderCell('상태', flex: 2),
        _buildHeaderCell('주문자 정보', flex: 3),
        _buildHeaderCell('받는사람 정보', flex: 3),
        _buildHeaderCell('상품/금액', flex: 2),
        _buildHeaderCell('액션', flex: 2),
      ],
    ),
  );
}

// 헤더 셀
Widget _buildHeaderCell(String title, {int flex = 1}) {
  return Expanded(
    flex: flex,
    child: Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      textAlign: TextAlign.center,
    ),
  );
}

// 테이블 행
Widget _buildTableRow(int orderId, List<Order> items, Map<String, dynamic> info) {
  final status = info['status'] as String? ?? 'confirmed';
  final totalAmount = (info['total_amount'] as num?)?.toInt() ?? 0;
  final cancellation = info['cancellation'] as OrderCancellation?;
  final partialCancellations = info['partial_cancellations'] as List<OrderItemCancellation>? ?? [];
  final orderNumber = _formatOrderNumber(orderId);
  
  // 취소 관련 상태 확인
  final hasCancellationRequest = cancellation != null || partialCancellations.any((pc) => pc.status == 'pending');
  final canCancel = ['confirmed', 'preparing'].contains(status);

  return Container(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(color: Colors.grey[300]!),
        left: BorderSide(color: Colors.grey[300]!),
        right: BorderSide(color: Colors.grey[300]!),
      ),
      color: hasCancellationRequest ? Colors.orange[50] : Colors.white,
    ),
    child: Row(
      children: [
        // 주문번호
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                orderNumber,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                DateFormat('HH:mm').format(info['created_at']),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        
        // 상태
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildStatusChip(status),
              if (cancellation != null || partialCancellations.isNotEmpty) ...[
                const SizedBox(height: 2),
                _buildCancellationInfo(cancellation, partialCancellations),
              ],
            ],
          ),
        ),
        
        // 주문자 정보
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                info['user_name'] ?? '정보없음',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              Text(
                info['user_phone'] ?? '정보없음',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        
        // 받는사람 정보
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                info['recipient_name'] ?? '정보없음',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              Text(
                info['recipient_phone'] ?? '정보없음',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        
        // 상품/금액
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${NumberFormat('#,###').format(totalAmount)}원',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.blue,
                ),
              ),
              Text(
                '${items.length}개 상품',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        
        // 액션
        Expanded(
          flex: 2,
          child: _buildCompactActionButton(
            orderId, 
            items, 
            info, 
            partialCancellations, 
            hasCancellationRequest, 
            canCancel
          ),
        ),
      ],
    ),
  );
}

// 취소 정보 표시 (압축된 형태)
Widget _buildCancellationInfo(
  OrderCancellation? cancellation,
  List<OrderItemCancellation> partialCancellations,
) {
  if (cancellation != null && partialCancellations.isNotEmpty) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.red[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '전체+부분',
        style: TextStyle(
          fontSize: 8,
          color: Colors.red[700],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  } else if (cancellation != null) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.orange[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '전체취소',
        style: TextStyle(
          fontSize: 8,
          color: Colors.orange[700],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  } else if (partialCancellations.isNotEmpty) {
    final pending = partialCancellations.where((pc) => pc.status == 'pending').length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '부분${partialCancellations.length}건${pending > 0 ? '($pending대기)' : ''}',
        style: TextStyle(
          fontSize: 8,
          color: Colors.blue[700],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  return const SizedBox.shrink();
}

// 압축된 액션 버튼
Widget _buildCompactActionButton(
  int orderId,
  List<Order> items,
  Map<String, dynamic> info,
  List<OrderItemCancellation> partialCancellations,
  bool hasCancellationRequest,
  bool canCancel,
) {
  if (hasCancellationRequest) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showOrderDetails(context, orderId, info, items, partialCancellations),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          padding: const EdgeInsets.symmetric(vertical: 4),
        ),
        child: const Text(
          '취소처리',
          style: TextStyle(fontSize: 10, color: Colors.white),
        ),
      ),
    );
  } else if (canCancel) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _showOrderDetails(context, orderId, info, items, partialCancellations),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 4),
        ),
        child: const Text(
          '주문취소',
          style: TextStyle(fontSize: 10),
        ),
      ),
    );
  } else {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => _showOrderDetails(context, orderId, info, items, partialCancellations),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 4),
        ),
        child: const Text(
          '상세보기',
          style: TextStyle(fontSize: 10),
        ),
      ),
    );
  }
}

// 상태 칩 (크기 조정)
Widget _buildStatusChip(String status) {
  Color color = _getStatusColor(status);
  String label = _getStatusLabel(status);

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

// ✅ 부분취소 데이터 조회 메서드 추가
void _fetchPartialCancellations() async {
  try {
    final partialCancellations = await ref.read(orderRepositoryProvider).fetchPartialCancellations();
    if (mounted) {
      setState(() {
        _partialCancellations = partialCancellations;
      });
      debugPrint('✅ Partial cancellations loaded: ${_partialCancellations.length}');
    }
  } catch (e) {
    debugPrint('❌ Failed to load partial cancellations: $e');
    if (mounted) {
      setState(() {
        _partialCancellations = [];
      });
    }
  }
}
  

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

  return FutureBuilder<List<dynamic>>(
    future: Future.wait([
      ref.read(orderRepositoryProvider).fetchOrdersWithCancellations(),
      ref.read(orderRepositoryProvider).fetchPartialCancellations(),
    ]),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      final orderData = snapshot.data![0] as Map<int, Map<String, dynamic>>;
      final partialCancellations = snapshot.data![1] as List<OrderItemCancellation>;

      // 주문 데이터 준비
      Map<int, List<Order>> groupedOrders = {};
      Map<int, Map<String, dynamic>> orderInfo = {};
      
      for (final order in orders) {
        final actualOrderId = order.orderId ?? order.participantId;
        
        if (!groupedOrders.containsKey(actualOrderId)) {
          groupedOrders[actualOrderId] = [];
          
          final data = orderData[actualOrderId];
          final cancellation = data?['cancellation'] as OrderCancellation?;
          final orderPartialCancellations = partialCancellations
              .where((pc) => pc.orderId == actualOrderId)
              .toList();
          
          String displayStatus;
          if (cancellation != null) {
            switch (cancellation.status) {
              case 'pending': displayStatus = 'cancel_requested'; break;
              case 'approved': displayStatus = 'cancelled'; break;
              case 'rejected': displayStatus = 'cancel_rejected'; break;
              default: displayStatus = data?['order_status'] ?? 'confirmed';
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
            'partial_cancellations': orderPartialCancellations,
            'created_at': DateTime.now(), // 실제로는 주문 생성일
            'user_name': order.userName ?? '정보없음', // 주문자명 추가
            'user_phone': order.userPhone ?? '정보없음', // 주문자 전화번호 추가
          };
        }
        groupedOrders[actualOrderId]!.add(order);
      }

      // 필터링 적용
      final filteredOrders = _applyFilters(groupedOrders, orderInfo);
      
      // 날짜별 그룹화
      final groupedByDate = _groupOrdersByDate(filteredOrders, orderInfo);
      
      return _buildDateGroupedOrderList(groupedByDate, orderInfo);
    },
  );
}

// 필터 적용
Map<int, List<Order>> _applyFilters(
  Map<int, List<Order>> groupedOrders,
  Map<int, Map<String, dynamic>> orderInfo,
) {
  return Map.fromEntries(
    groupedOrders.entries.where((entry) {
      final orderId = entry.key;
      final info = orderInfo[orderId]!;
      
      // 검색 필터
      if (_searchQuery.isNotEmpty) {
        final orderNumber = _formatOrderNumber(orderId);
        final recipientName = info['recipient_name']?.toString().toLowerCase() ?? '';
        final userName = info['user_name']?.toString().toLowerCase() ?? '';
        final recipientPhone = info['recipient_phone']?.toString() ?? '';
        final userPhone = info['user_phone']?.toString() ?? '';
        final query = _searchQuery.toLowerCase();
        
        if (!orderNumber.contains(query) &&
            !recipientName.contains(query) &&
            !userName.contains(query) &&
            !recipientPhone.contains(query) &&
            !userPhone.contains(query)) {
          return false;
        }
      }
      
      // 상태 필터
      if (_selectedStatus != '전체') {
        final status = info['status'] as String;
        final mappedStatus = _mapStatusToFilter(status);
        if (mappedStatus != _selectedStatus) {
          return false;
        }
      }
      
      return true;
    }),
  );
}

// 상태를 필터 옵션에 매핑
String _mapStatusToFilter(String status) {
  switch (status) {
    case 'confirmed': return '결제완료';
    case 'preparing': return '상품준비중';
    case 'shipped': return '배송중';
    case 'delivered': return '배송완료';
    case 'cancelled':
    case 'cancel_requested':
    case 'cancel_rejected': return '교환반품';
    default: return '결제완료';
  }
}

// 날짜별 그룹화
Map<String, Map<int, List<Order>>> _groupOrdersByDate(
  Map<int, List<Order>> orders,
  Map<int, Map<String, dynamic>> orderInfo,
) {
  Map<String, Map<int, List<Order>>> grouped = {};
  
  for (final entry in orders.entries) {
    final orderId = entry.key;
    final orderItems = entry.value;
    final createdAt = orderInfo[orderId]!['created_at'] as DateTime;
    final dateKey = DateFormat('yyyy-MM-dd').format(createdAt);
    
    grouped[dateKey] ??= {};
    grouped[dateKey]![orderId] = orderItems;
  }
  
  return grouped;
}



void _showOrderDetails(
  BuildContext context,
  int orderId,
  Map<String, dynamic> info,
  List<Order> items,
  List<OrderItemCancellation> partialCancellations,
) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Text('주문 상세: ORD-$orderId'),
          const Spacer(),
          if (partialCancellations.isNotEmpty) ...[
            const SizedBox(width: 16),
            _buildPartialCancellationSummary(partialCancellations),
          ],
        ],
      ),
      content: SizedBox(
        width: 600,
        height: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 기존 정보들...
            Text('배송지: ${info['shipping_address'] ?? '주소없음'}'),
            const SizedBox(height: 16),
            
            if (items.isNotEmpty) ...[
              const Text('주문 상품:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: Text(item.productName)),
                    Text('수량: ${item.quantity}'),
                  ],
                ),
              )),
            ],
            
            // ✅ 부분취소 섹션 개선
            if (partialCancellations.isNotEmpty) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text('부분취소 요청:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 16),
                  Text(
                    _getPartialCancellationText(partialCancellations),
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              Expanded(
                child: ListView.builder(
                  itemCount: partialCancellations.length,
                  itemBuilder: (context, index) {
                    final pc = partialCancellations[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: pc.status == 'pending' 
                          ? Colors.orange.shade50
                          : pc.status == 'approved' 
                              ? Colors.green.shade50 
                              : Colors.red.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    pc.productName ?? '상품명 없음', 
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                                _buildPartialCancelStatusChip(pc.status),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('취소 수량: ${pc.cancelQuantity}개'),
                            Text('환불 금액: ${NumberFormat('#,###').format(pc.refundAmount)}원'),
                            Text('사유: ${pc.cancelReason}'),
                            if (pc.cancelDetail?.isNotEmpty == true)
                              Text('상세: ${pc.cancelDetail}'),
                            Text(
                              '요청일: ${DateFormat('yyyy-MM-dd HH:mm').format(pc.requestedAt)}',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                            
                            // 처리 정보 표시
                            if (pc.status != 'pending') ...[
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
                                      '처리 결과: ${pc.status == 'approved' ? '승인됨' : '거부됨'}',
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    if (pc.adminNote?.isNotEmpty == true)
                                      Text('관리자 메모: ${pc.adminNote}'),
                                    if (pc.processedAt != null)
                                      Text(
                                        '처리일: ${DateFormat('yyyy-MM-dd HH:mm').format(pc.processedAt!)}',
                                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                            
                            // 대기 중인 항목에 액션 버튼
                            if (pc.status == 'pending') ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _handlePartialCancelAction(pc, false);
                                    },
                                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                                    child: const Text('거부'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _handlePartialCancelAction(pc, true);
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                    child: const Text('승인'),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('닫기'),
        ),
      ],
    ),
  );
}


  // ✅ 부분취소 상태 칩
Widget _buildPartialCancelStatusChip(String status) {
  Color color;
  String label;
  
  switch (status) {
    case 'pending':
      color = Colors.orange;
      label = '대기';
      break;
    case 'approved':
      color = Colors.green;
      label = '승인';
      break;
    case 'rejected':
      color = Colors.red;
      label = '거부';
      break;
    default:
      color = Colors.grey;
      label = status;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      label,
      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
    ),
  );
}

// ✅ 부분취소 액션 처리
void _handlePartialCancelAction(OrderItemCancellation pc, bool approve) async {
  String adminNote = '';
  final action = approve ? '승인' : '거부';

  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('부분취소 $action'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('상품: ${pc.productName}'),
          Text('취소 수량: ${pc.cancelQuantity}개'),
          Text('환불 금액: ${NumberFormat('#,###').format(pc.refundAmount)}원'),
          const SizedBox(height: 16),
          const Text('관리자 메모:'),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: '$action 사유를 입력해주세요',
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
            onChanged: (value) => adminNote = value,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(adminNote),
          style: ElevatedButton.styleFrom(
            backgroundColor: approve ? Colors.blue : Colors.red,
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
            .approvePartialCancellation(pc.id, result);
      } else {
        await ref.read(orderRepositoryProvider)
            .rejectPartialCancellation(pc.id, result);
      }
      
      // ✅ 강화된 새로고침
      debugPrint('🔄 Refreshing after partial cancellation $action');
      
      // 1. OrderViewModel 새로고침
      await ref.read(orderViewModelProvider(widget.orderType).notifier).fetchOrders();
      
      // 2. 부분취소 데이터도 새로고침
      _fetchPartialCancellations();
      
      // 3. 약간의 지연 후 한 번 더
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          ref.read(orderViewModelProvider(widget.orderType).notifier).fetchOrders();
        }
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('부분취소 요청이 ${action}되었습니다.'),
            backgroundColor: approve ? Colors.blue : Colors.red,
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
    case 'confirmed': return '결제완료';
    case 'processing': return '처리중';
    case 'shipped': return '배송중';
    case 'cancel_requested': return '취소요청';
    default: return status;
  }
}


// ✅ 부분취소 상태별 요약 위젯 생성
Widget _buildPartialCancellationSummary(List<OrderItemCancellation> partialCancellations) {
  if (partialCancellations.isEmpty) return const SizedBox.shrink();
  
  // 상태별 카운트
  final pending = partialCancellations.where((pc) => pc.status == 'pending').length;
  final approved = partialCancellations.where((pc) => pc.status == 'approved').length;
  final rejected = partialCancellations.where((pc) => pc.status == 'rejected').length;
  
  List<Widget> statusChips = [];
  
  if (pending > 0) {
    statusChips.add(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '대기 ${pending}건',
          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
  
  if (approved > 0) {
    statusChips.add(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '승인 ${approved}건',
          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
  
  if (rejected > 0) {
    statusChips.add(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '거부 ${rejected}건',
          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
  
  return Wrap(
    spacing: 4,
    runSpacing: 4,
    children: statusChips,
  );
}

// ✅ 부분취소 텍스트 생성 함수
String _getPartialCancellationText(List<OrderItemCancellation> partialCancellations) {
  if (partialCancellations.isEmpty) return '';
  
  final pending = partialCancellations.where((pc) => pc.status == 'pending').length;
  final approved = partialCancellations.where((pc) => pc.status == 'approved').length;
  final rejected = partialCancellations.where((pc) => pc.status == 'rejected').length;
  
  List<String> statusTexts = [];
  
  if (pending > 0) statusTexts.add('대기 ${pending}건');
  if (approved > 0) statusTexts.add('승인 ${approved}건');
  if (rejected > 0) statusTexts.add('거부 ${rejected}건');
  
  return statusTexts.join(' · ');
}
}