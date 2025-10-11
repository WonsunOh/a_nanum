import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

import '../../../data/models/order_model.dart';
// 🔥🔥🔥 수정: 누락된 모델 파일 임포트
import '../../../data/models/order_cancellation_model.dart';
import '../../../data/models/order_item_cancellation_model.dart';
import '../viewmodel/combined_cancellation_viewmodel.dart';
import '../viewmodel/order_viewmodel.dart';

class OrderManagementScreen extends ConsumerStatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  ConsumerState<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends ConsumerState<OrderManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  final List<String> _selectedOrderIds = [];
  bool _isAllSelected = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    
    // 첫 로딩 시 각 탭에 필요한 데이터를 불러옵니다.
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
    // 탭이 변경될 때마다 해당 탭의 데이터를 새로고침합니다.
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
      // isRefresh는 ViewModel 내부에서 처리하지 않으므로 search만 호출
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
          _buildFilterControls(),
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

  Widget _buildFilterControls() {
    final isOrderTab = _tabController.index == 0;

    return Row(
      children: [
        if (isOrderTab)
          // Consumer를 사용하여 ViewModel 상태에 따라 Dropdown을 빌드합니다.
          Consumer(builder: (context, ref, child) {
            final notifier = ref.read(orderViewModelProvider.notifier);
            // orderViewModelProvider의 상태를 직접 watch하지는 않고 notifier만 사용
            return DropdownButton<String>(
              value: notifier.selectedStatus, // Notifier에서 직접 상태를 가져옴
              onChanged: (String? newValue) {
                if (newValue == null) return;
                notifier.setSelectedStatus(newValue);
                notifier.fetchOrders(isRefresh: true);
              },
              // '교환/반품' 등 필요한 상태를 여기에 추가할 수 있습니다.
              items: (OrderStatus.values.where((s) => s != OrderStatus.cancelled && s != OrderStatus.cancellationRequested).map((s) => s.displayName).toList()..insert(0, '전체'))
                  .map<DropdownMenuItem<String>>((String value) => DropdownMenuItem<String>(value: value, child: Text(value)))
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
                  .map<DropdownMenuItem<String>>((String value) => DropdownMenuItem<String>(value: value, child: Text(value)))
                  .toList(),
            );
          }),
        const Spacer(),
        if (isOrderTab && _selectedOrderIds.isNotEmpty)
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle_outline),
            label: Text('${_selectedOrderIds.length}건 상품준비중으로 변경'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
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
            decoration: const InputDecoration(labelText: '검색 (주문번호, 주문자)', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10)),
            onSubmitted: (_) => _applyFilters(),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          icon: const Icon(Icons.search),
          label: const Text('검색'),
          onPressed: () => _applyFilters(),
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)),
        ),
      ],
    );
  }

  // ============== 주문 관리 탭 ==============
  Widget _buildOrdersTab() {
    final orderState = ref.watch(orderViewModelProvider);
    return orderState.when(
      data: (orders) => _buildGroupedOrderList(orders),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text("오류: $e")),
    );
  }

  Widget _buildGroupedOrderList(List<OrderModel> orders) {
    if (orders.isEmpty) return const Center(child: Text("표시할 주문 내역이 없습니다."));
    final groupedOrders = groupBy(orders, (OrderModel o) => DateFormat('yyyy-MM-dd').format(o.orderDate));
    final dateKeys = groupedOrders.keys.toList();

    return ListView.builder(
      itemCount: dateKeys.length,
      itemBuilder: (context, index) {
        final dateKey = dateKeys[index];
        final ordersForDate = groupedOrders[dateKey]!;
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(ordersForDate.first.orderDate),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(width: double.infinity, child: _buildOrderDataTable(ordersForDate)),
            ],
          ),
        );
      },
    );
  }
  
  DataTable _buildOrderDataTable(List<OrderModel> orders) {
    final confirmedOrders = orders.where((o) => o.status == OrderStatus.confirmed).toList();
    return DataTable(
      showCheckboxColumn: true,
      columns: [
        DataColumn(
          label: Checkbox(
            value: confirmedOrders.isNotEmpty && _selectedOrderIds.length == confirmedOrders.length,
            onChanged: (bool? value) {
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
        const DataColumn(label: Text('주문시간')),
        const DataColumn(label: Text('주문ID')),
        const DataColumn(label: Text('받는사람')),
        const DataColumn(label: Text('결제금액')),
        const DataColumn(label: Text('상태')),
        const DataColumn(label: Text('상태변경')),
      ],
      rows: orders.map((order) {
        final isSelected = _selectedOrderIds.contains(order.orderId);
        return DataRow(
          selected: isSelected,
          cells: [
            DataCell(
              order.status == OrderStatus.confirmed
                  ? Checkbox(
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedOrderIds.add(order.orderId);
                          } else {
                            _selectedOrderIds.remove(order.orderId);
                          }
                          _isAllSelected = confirmedOrders.isNotEmpty && _selectedOrderIds.length == confirmedOrders.length;
                        });
                      },
                    )
                  : const SizedBox.shrink(),
            ),
            DataCell(Text(DateFormat('HH:mm').format(order.orderDate))),
            DataCell(SelectableText(order.orderId)),
            DataCell(Text(order.recipientName)),
            DataCell(Text('${NumberFormat('#,###').format(order.totalAmount)}원')),
            DataCell(Chip(
              label: Text(order.status.displayName, style: const TextStyle(color: Colors.white, fontSize: 12)),
              backgroundColor: order.status.color,
            )),
            DataCell(PopupMenuButton<OrderStatus>(
              onSelected: (newStatus) => ref.read(orderViewModelProvider.notifier).updateOrderStatus(order.orderId, newStatus),
              itemBuilder: (context) => OrderStatus.values.map((s) => PopupMenuItem(value: s, child: Text(s.displayName))).toList(),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [Text('변경'), Icon(Icons.arrow_drop_down)]),
            )),
          ],
        );
      }).toList(),
    );
  }
  
  // ============== 취소/반품 관리 탭 (통합) ==============
  Widget _buildCombinedCancellationsTab() {
    final state = ref.watch(combinedCancellationViewModelProvider);
    final notifier = ref.read(combinedCancellationViewModelProvider.notifier);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return Center(child: Text("오류: ${state.error}"));
    }
    if (state.fullCancellations.isEmpty && state.partialCancellations.isEmpty) {
      return const Center(child: Text("취소/반품 내역이 없습니다."));
    }

    // 전체취소와 부분취소를 합쳐서 하나의 리스트로 만듭니다.
    final allCancellations = [
      ...state.fullCancellations.map((c) => {'type': 'full', 'data': c, 'date': c.requestedAt}),
      ...state.partialCancellations.map((c) => {'type': 'partial', 'data': c, 'date': c.requestedAt}),
    ];
    // 최신 요청이 위로 오도록 정렬합니다.
    allCancellations.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    return SingleChildScrollView(
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('요청일시')),
            DataColumn(label: Text('유형')),
            DataColumn(label: Text('주문ID')),
            DataColumn(label: Text('주문자/취소상품')),
            DataColumn(label: Text('금액/수량')),
            DataColumn(label: Text('상태')),
            DataColumn(label: Text('관리')),
          ],
          rows: allCancellations.map((item) {
            if (item['type'] == 'full') {
              // 🔥🔥🔥 수정: 타입을 명시적으로 지정
              final c = item['data'] as OrderCancellation;
              return DataRow(cells: [
                DataCell(Text(DateFormat('yyyy-MM-dd HH:mm').format(c.requestedAt))),
                const DataCell(Chip(label: Text('전체취소'), backgroundColor: Colors.red, labelStyle: TextStyle(color: Colors.white))),
                DataCell(SelectableText(c.order.orderId)),
                DataCell(Text(c.order.userName)),
                DataCell(Text('${NumberFormat('#,###').format(c.refundedAmount)}원')),
                DataCell(Chip(label: Text(c.status), backgroundColor: c.status == 'pending' ? Colors.orange : (c.status == 'approved' ? Colors.green : Colors.red), labelStyle: const TextStyle(color: Colors.white))),
                DataCell(
                  c.status == 'pending' ? Row(children: [
                    ElevatedButton(child: const Text('승인'), onPressed: () => notifier.approveFullCancellation(c.cancellationId)),
                    const SizedBox(width: 8),
                    OutlinedButton(child: const Text('거절'), onPressed: () => _showRejectDialog(c.cancellationId, false)),
                  ]) : Text(c.status == 'approved' ? '승인됨' : '거절됨'),
                ),
              ]);
            } else { // partial
              // 🔥🔥🔥 수정: 타입을 명시적으로 지정
              final c = item['data'] as OrderItemCancellation;
              return DataRow(cells: [
                DataCell(Text(DateFormat('yyyy-MM-dd HH:mm').format(c.requestedAt))),
                const DataCell(Chip(label: Text('부분취소'), backgroundColor: Colors.deepOrangeAccent, labelStyle: TextStyle(color: Colors.white))),
                DataCell(SelectableText(c.order.orderId)),
                DataCell(Text(c.orderItem.productName)),
                DataCell(Text('${c.cancelledQuantity}개')),
                DataCell(Chip(label: Text(c.status), backgroundColor: c.status == 'pending' ? Colors.orange : (c.status == 'approved' ? Colors.green : Colors.red), labelStyle: const TextStyle(color: Colors.white))),
                DataCell(
                  c.status == 'pending' ? Row(children: [
                    ElevatedButton(child: const Text('승인'), onPressed: () => notifier.approvePartialCancellation(c.itemCancellationId)),
                    const SizedBox(width: 8),
                    OutlinedButton(child: const Text('거절'), onPressed: () => _showRejectDialog(c.itemCancellationId, true)),
                  ]) : Text(c.status == 'approved' ? '승인됨' : '거절됨'),
                ),
              ]);
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
            decoration: const InputDecoration(labelText: '거절 사유를 입력하세요'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
            ElevatedButton(
              onPressed: () {
                if (reasonController.text.isNotEmpty) {
                  final notifier = ref.read(combinedCancellationViewModelProvider.notifier);
                  if (isPartial) {
                    notifier.rejectPartialCancellation(cancellationId, reasonController.text);
                  } else {
                    notifier.rejectFullCancellation(cancellationId, reasonController.text);
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

