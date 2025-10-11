import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

import '../../../data/models/order_model.dart';
import '../../../data/models/order_cancellation_model.dart';
import '../../../data/models/order_item_cancellation_model.dart';
import '../viewmodel/combined_cancellation_viewmodel.dart';
import '../viewmodel/order_viewmodel.dart';
import 'widgets/bulk_tracking_upload_dialog.dart';
import 'widgets/date_range_filter_widget.dart';
import 'widgets/order_detail_dialog.dart';
import 'widgets/order_loading_widgets.dart'; // ✅ 추가
import 'widgets/order_status_badge_widget.dart'; // ✅ 추가

class OrderManagementScreen extends ConsumerStatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  ConsumerState<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends ConsumerState<OrderManagementScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  final List<String> _selectedOrderIds = [];
  bool _isAllSelected = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderViewModelProvider.notifier).fetchOrders(isRefresh: true);
      ref.read(combinedCancellationViewModelProvider.notifier).fetchCancellations();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      _searchController.clear();
    });
    _applyFilters(isRefresh: true);
  }

  void _applyFilters({bool isRefresh = false}) {
    final query = _searchController.text;
    if (_tabController.index == 0) {
      final notifier = ref.read(orderViewModelProvider.notifier);
      notifier.setSearchQuery(query);
      notifier.fetchOrders(isRefresh: isRefresh);
    } else {
      final notifier = ref.read(combinedCancellationViewModelProvider.notifier);
      notifier.search(query);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("주문/취소 관리", style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          TabBar(
            controller: _tabController,
            tabs: const [ Tab(text: '주문 관리'), Tab(text: '취소/반품 관리') ],
          ),
          const SizedBox(height: 16),
          if (_tabController.index == 0) ...[
            const DateRangeFilterWidget(),
            const SizedBox(height: 16),
          ],
          _buildFilterControls(),
          const SizedBox(height: 16),
          if (_tabController.index == 0)
            _buildOrderStatsSummary(),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersTab(),
                _buildCombinedCancellationsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 주문 통계 요약 위젯
  Widget _buildOrderStatsSummary() {
    final orderState = ref.watch(orderViewModelProvider);
    
    return orderState.when(
      data: (orders) {
        if (orders.isEmpty) return const SizedBox.shrink();
        
        final totalOrders = orders.length;
        final totalAmount = orders.fold<int>(0, (sum, order) => sum + order.totalAmount);
        
        final statusCounts = <OrderStatus, int>{};
        for (final order in orders) {
          statusCounts[order.status] = (statusCounts[order.status] ?? 0) + 1;
        }
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.blue.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.analytics, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Text(
                    '조회 결과 통계',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      '총 주문',
                      '$totalOrders건',
                      Icons.shopping_cart,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      '총 매출',
                      '₩${NumberFormat('#,###').format(totalAmount)}',
                      Icons.payments,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ...statusCounts.entries.take(3).map((entry) {
                    return Expanded(
                      child: _buildStatCard(
                        entry.key.displayName,
                        '${entry.value}건',
                        Icons.receipt,
                        entry.key.color,
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterControls() {
    final isOrderTab = _tabController.index == 0;

    return Row(
      children: [
        if (isOrderTab)
          Consumer(builder: (context, ref, child) {
            final notifier = ref.read(orderViewModelProvider.notifier);
            return DropdownButton<String>(
              value: notifier.selectedStatus,
              onChanged: (String? newValue) {
                if (newValue == null) return;
                notifier.setSelectedStatus(newValue);
                notifier.fetchOrders(isRefresh: true);
              },
              items: (OrderStatus.values
                      .where((s) =>
                          s != OrderStatus.cancelled &&
                          s != OrderStatus.cancellationRequested)
                      .map((s) => s.displayName)
                      .toList()
                    ..insert(0, '전체'))
                  .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ))
                  .toList(),
            );
          })
        else
          Consumer(builder: (context, ref, child) {
            final notifier = ref.read(combinedCancellationViewModelProvider.notifier);
            final state = ref.watch(combinedCancellationViewModelProvider);
            return DropdownButton<String>(
              value: state.selectedStatus,
              onChanged: (String? newValue) {
                if (newValue == null) return;
                notifier.filterByStatus(newValue);
              },
              items: ['전체', 'pending', 'approved', 'rejected']
                  .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ))
                  .toList(),
            );
          }),
        const Spacer(),
        
        if (isOrderTab)
          OutlinedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const BulkTrackingUploadDialog(),
              );
            },
            icon: const Icon(Icons.upload_file),
            label: const Text('송장번호 일괄등록'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        
        if (isOrderTab) const SizedBox(width: 8),
        
        if (isOrderTab && _selectedOrderIds.isNotEmpty)
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle_outline),
            label: Text('${_selectedOrderIds.length}건 상품준비중으로 변경'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: () {
              ref.read(orderViewModelProvider.notifier).changeOrdersToPreparing(_selectedOrderIds);
              setState(() {
                _selectedOrderIds.clear();
                _isAllSelected = false;
              });
            },
          ),
        const SizedBox(width: 16),
        SizedBox(
          width: 250,
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: '검색 (주문번호, 주문자)',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
            ),
            onSubmitted: (_) => _applyFilters(),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          icon: const Icon(Icons.search),
          label: const Text('검색'),
          onPressed: () => _applyFilters(),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
      ],
    );
  }

  // ============== 주문 관리 탭 ==============
  Widget _buildOrdersTab() {
    final orderState = ref.watch(orderViewModelProvider);
    return orderState.when(
      data: (orders) {
        if (orders.isEmpty) {
          return const OrderEmptyState(
            message: '표시할 주문 내역이 없습니다',
            subtitle: '검색 조건을 변경하거나 새로운 주문을 기다려주세요',
          );
        }
        return _buildGroupedOrderList(orders);
      },
      loading: () => const OrderSkeletonLoader(),
      error: (e, s) => OrderErrorState(
        error: e,
        onRetry: () {
          ref.read(orderViewModelProvider.notifier).fetchOrders(isRefresh: true);
        },
      ),
    );
  }

  Widget _buildGroupedOrderList(List<OrderModel> orders) {
    final groupedOrders = groupBy(
      orders,
      (OrderModel o) => DateFormat('yyyy-MM-dd').format(o.orderDate),
    );
    final dateKeys = groupedOrders.keys.toList();

    return ListView.builder(
      itemCount: dateKeys.length,
      itemBuilder: (context, index) {
        final dateKey = dateKeys[index];
        final ordersForDate = groupedOrders[dateKey]!;
        
        // ✅ Fade-in 애니메이션 적용
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 50)),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.grey.shade50, Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 20, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR')
                            .format(ordersForDate.first.orderDate),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Text(
                          '${ordersForDate.length}건',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: _buildOrderDataTable(ordersForDate),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  DataTable _buildOrderDataTable(List<OrderModel> orders) {
    final confirmedOrders = orders
        .where((o) => o.status == OrderStatus.confirmed)
        .toList();
    
    return DataTable(
      showCheckboxColumn: false,
      headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
      columns: [
        DataColumn(
          label: Checkbox(
            value: confirmedOrders.isNotEmpty && 
                   confirmedOrders.every((o) => _selectedOrderIds.contains(o.orderId)),
            onChanged: confirmedOrders.isEmpty ? null : (bool? value) {
              setState(() {
                _isAllSelected = value ?? false;
                _selectedOrderIds.clear();
                if (_isAllSelected) {
                  _selectedOrderIds.addAll(confirmedOrders.map((o) => o.orderId));
                }
              });
            },
          ),
        ),
        const DataColumn(
          label: Text('주문시간', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        const DataColumn(
          label: Text('주문ID', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        const DataColumn(
          label: Text('받는사람', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        const DataColumn(
          label: Text('결제금액', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        const DataColumn(
          label: Text('상태', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        const DataColumn(
          label: Text('관리', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
      rows: orders.map((order) {
        final isSelected = _selectedOrderIds.contains(order.orderId);
        final isConfirmed = order.status == OrderStatus.confirmed;
        
        return DataRow(
          onSelectChanged: (_) {
            showDialog(
              context: context,
              builder: (context) => OrderDetailDialog(order: order),
            );
          },
          selected: isSelected,
          cells: [
            DataCell(
              isConfirmed
                  ? Checkbox(
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedOrderIds.add(order.orderId);
                          } else {
                            _selectedOrderIds.remove(order.orderId);
                          }
                          _isAllSelected = confirmedOrders.isNotEmpty && 
                              confirmedOrders.every((o) => 
                                  _selectedOrderIds.contains(o.orderId));
                        });
                      },
                    )
                  : const SizedBox(width: 24),
              onTap: isConfirmed ? () {
                setState(() {
                  if (_selectedOrderIds.contains(order.orderId)) {
                    _selectedOrderIds.remove(order.orderId);
                  } else {
                    _selectedOrderIds.add(order.orderId);
                  }
                  _isAllSelected = confirmedOrders.isNotEmpty && 
                      confirmedOrders.every((o) => 
                          _selectedOrderIds.contains(o.orderId));
                });
              } : null,
            ),
            DataCell(Text(DateFormat('HH:mm').format(order.orderDate))),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    order.orderId,
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: order.orderId));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('주문번호 복사: ${order.orderId}'),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                          width: 300,
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.copy, size: 14, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              onTap: null,
            ),
            DataCell(Text(order.recipientName)),
            DataCell(
              Text(
                '${NumberFormat('#,###').format(order.totalAmount)}원',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            DataCell(OrderStatusBadge(status: order.status)), // ✅ 개선된 배지
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => OrderDetailDialog(order: order),
                      );
                    },
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('상세', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: const Size(0, 32),
                    ),
                  ),
                  const SizedBox(width: 4),
                  PopupMenuButton<OrderStatus>(
                    tooltip: '상태 변경',
                    onSelected: (newStatus) {
                      ref.read(orderViewModelProvider.notifier).updateOrderStatus(
                            order.orderId,
                            newStatus,
                          );
                    },
                    itemBuilder: (context) => OrderStatus.values
                        .map((s) => PopupMenuItem(
                              value: s,
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: s.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(s.displayName),
                                ],
                              ),
                            ))
                        .toList(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('상태변경', style: TextStyle(fontSize: 12)),
                          Icon(Icons.arrow_drop_down, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {},
            ),
          ],
        );
      }).toList(),
    );
  }

  // ============== 취소/반품 관리 탭 ==============
  Widget _buildCombinedCancellationsTab() {
    final state = ref.watch(combinedCancellationViewModelProvider);
    final notifier = ref.read(combinedCancellationViewModelProvider.notifier);

    if (state.isLoading) {
      return const OrderSkeletonLoader();
    }
    
    if (state.error != null) {
      return OrderErrorState(
        error: state.error!,
        onRetry: () => notifier.fetchCancellations(),
      );
    }
    
    if (state.fullCancellations.isEmpty && state.partialCancellations.isEmpty) {
      return const OrderEmptyState(
        message: '취소/반품 내역이 없습니다',
        subtitle: '취소 요청이 들어오면 여기에 표시됩니다',
      );
    }

    final allCancellations = [
      ...state.fullCancellations.map((c) => {
        'type': 'full',
        'data': c,
        'date': c.requestedAt,
      }),
      ...state.partialCancellations.map((c) => {
        'type': 'partial',
        'data': c,
        'date': c.requestedAt,
      }),
    ];
    allCancellations.sort((a, b) => 
        (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    return SingleChildScrollView(
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
          columns: const [
            DataColumn(
              label: Text('요청일시', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text('유형', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text('주문ID', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text('주문자/취소상품', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text('금액/수량', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text('상태', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text('관리', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
          rows: allCancellations.map((item) {
            if (item['type'] == 'full') {
              final c = item['data'] as OrderCancellation;
              return DataRow(
                cells: [
                  DataCell(
                    Text(DateFormat('yyyy-MM-dd HH:mm').format(c.requestedAt)),
                  ),
                  DataCell(
                    CancellationTypeBadge(isFullCancellation: true), // ✅ 개선된 배지
                  ),
                  DataCell(SelectableText(c.order.orderId)),
                  DataCell(Text(c.order.userName)),
                  DataCell(
                    Text('${NumberFormat('#,###').format(c.refundedAmount)}원'),
                  ),
                  DataCell(
                    CancellationStatusBadge(status: c.status), // ✅ 개선된 배지
                  ),
                  DataCell(
                    c.status == 'pending'
                        ? Row(
                            children: [
                              ElevatedButton(
                                child: const Text('승인'),
                                onPressed: () => notifier.approveFullCancellation(
                                    c.cancellationId),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                child: const Text('거절'),
                                onPressed: () => 
                                    _showRejectDialog(c.cancellationId, false),
                              ),
                            ],
                          )
                        : Text(c.status == 'approved' ? '승인됨' : '거절됨'),
                  ),
                ],
              );
            } else {
              final c = item['data'] as OrderItemCancellation;
              return DataRow(
                cells: [
                  DataCell(
                    Text(DateFormat('yyyy-MM-dd HH:mm').format(c.requestedAt)),
                  ),
                  DataCell(
                    CancellationTypeBadge(isFullCancellation: false), // ✅ 개선된 배지
                  ),
                  DataCell(SelectableText(c.order.orderId)),
                  DataCell(Text(c.orderItem.productName)),
                  DataCell(Text('${c.cancelledQuantity}개')),
                  DataCell(
                    CancellationStatusBadge(status: c.status), // ✅ 개선된 배지
                  ),
                  DataCell(
                    c.status == 'pending'
                        ? Row(
                            children: [
                              ElevatedButton(
                                child: const Text('승인'),
                                onPressed: () => notifier.approvePartialCancellation(
                                    c.itemCancellationId),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                child: const Text('거절'),
                                onPressed: () => 
                                    _showRejectDialog(c.itemCancellationId, true),
                              ),
                            ],
                          )
                        : Text(c.status == 'approved' ? '승인됨' : '거절됨'),
                  ),
                ],
              );
            }
          }).toList(),
        ),
      ),
    );
  }

  void _showRejectDialog(String cancellationId, bool isPartial) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('취소 요청 거절'),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              labelText: '거절 사유를 입력하세요',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                if (reasonController.text.isNotEmpty) {
                  final notifier = 
                      ref.read(combinedCancellationViewModelProvider.notifier);
                  if (isPartial) {
                    notifier.rejectPartialCancellation(
                        cancellationId, reasonController.text);
                  } else {
                    notifier.rejectFullCancellation(
                        cancellationId, reasonController.text);
                  }
                  Navigator.pop(context);
                }
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }
}