// nanum_admin/lib/features/shop_management.dart/inventory/view/inventory_management_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/main_layout.dart';
import '../../../../data/models/inventory_model.dart';
import '../viewmodel/inventory_viewmodel.dart';

class InventoryManagementScreen extends ConsumerWidget {
  const InventoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(inventoryLogsProvider);
    final alertsAsync = ref.watch(stockAlertsProvider);

    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('재고 관리', style: Theme.of(context).textTheme.headlineSmall),
                ElevatedButton.icon(
                  onPressed: () => _showStockAdjustDialog(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('재고 조정'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 재고 부족 알림
            alertsAsync.when(
              data: (alerts) {
                if (alerts.isEmpty) {
                  return const SizedBox.shrink();
                }
                return _buildStockAlertsCard(context, alerts);
              },
              loading: () => const SizedBox.shrink(),
              error: (e, s) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 16),

            // 재고 변경 내역
            Expanded(
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '재고 변경 내역',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () {
                              ref
                                  .read(inventoryLogsProvider.notifier)
                                  .fetchLogs();
                            },
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: logsAsync.when(
                        data: (logs) => _buildLogsList(logs),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, s) => Center(child: Text('오류: $e')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockAlertsCard(BuildContext context, List<StockAlert> alerts) {
    final outOfStock = alerts.where((a) => a.isOutOfStock).length;
    final lowStock = alerts.where((a) => !a.isOutOfStock).length;

    return Card(
      color: Colors.orange[50],
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.orange, size: 28),
                const SizedBox(width: 12),
                Text(
                  '재고 알림',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[900],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (outOfStock > 0) ...[
                  _buildAlertChip('품절', outOfStock, Colors.red),
                  const SizedBox(width: 8),
                ],
                if (lowStock > 0) ...[
                  _buildAlertChip('재고 부족', lowStock, Colors.orange),
                ],
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: alerts.length,
                itemBuilder: (context, index) {
                  final alert = alerts[index];
                  return _buildAlertItem(context, alert);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(BuildContext context, StockAlert alert) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: alert.isOutOfStock ? Colors.red : Colors.orange,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            alert.productName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '재고',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              Text(
                '${alert.currentStock}개',
                style: TextStyle(
                  color: alert.isOutOfStock ? Colors.red : Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showQuickAdjustDialog(context, alert),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
                backgroundColor: Colors.blue,
              ),
              child: const Text(
                '입고',
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsList(List<InventoryLog> logs) {
    if (logs.isEmpty) {
      return const Center(child: Text('재고 변경 내역이 없습니다.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: logs.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final log = logs[index];
        return _buildLogItem(log);
      },
    );
  }

  Widget _buildLogItem(InventoryLog log) {
    IconData icon;
    Color color;
    String typeLabel;

    switch (log.type) {
      case 'in':
        icon = Icons.arrow_downward;
        color = Colors.green;
        typeLabel = '입고';
        break;
      case 'out':
        icon = Icons.arrow_upward;
        color = Colors.red;
        typeLabel = '출고';
        break;
      case 'adjust':
        icon = Icons.tune;
        color = Colors.blue;
        typeLabel = '조정';
        break;
      default:
        icon = Icons.help_outline;
        color = Colors.grey;
        typeLabel = log.type;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        log.productName,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$typeLabel: ${log.quantity}개'),
          Text(
            '${log.previousStock} → ${log.currentStock}',
            style: const TextStyle(fontSize: 12),
          ),
          if (log.reason != null)
            Text(
              '사유: ${log.reason}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
        ],
      ),
      trailing: Text(
        DateFormat('MM/dd HH:mm').format(log.createdAt),
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
    );
  }

  void _showStockAdjustDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('재고 조정'),
        content: const Text('상품 검색 및 재고 조정 기능은 곧 추가됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  // ✅ _showQuickAdjustDialog 수정 - dialogContext 제거
  void _showQuickAdjustDialog(BuildContext context, StockAlert alert) {
    final quantityController = TextEditingController();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => Consumer(
        // ✅ builder의 context를 dialogContext로 명명
        builder: (_, ref, __) {
          return AlertDialog(
            title: Text('${alert.productName} 입고'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('현재 재고: ${alert.currentStock}개'),
                const SizedBox(height: 16),
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(
                    labelText: '입고 수량',
                    border: OutlineInputBorder(),
                    suffixText: '개',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: '입고 사유 (선택)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(dialogContext), // ✅ dialogContext 사용
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final quantity = int.tryParse(quantityController.text);
                  if (quantity == null || quantity <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('올바른 수량을 입력해주세요.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  try {
                    await ref
                        .read(inventoryLogsProvider.notifier)
                        .adjustStock(
                          productId: alert.productId,
                          type: 'in',
                          quantity: quantity,
                          reason: reasonController.text.isEmpty
                              ? null
                              : reasonController.text,
                        );

                    if (dialogContext.mounted) {
                      // ✅ dialogContext 사용
                      Navigator.pop(dialogContext); // ✅ dialogContext 사용
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('입고 처리되었습니다.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      ref.invalidate(stockAlertsProvider);
                    }
                  } catch (e) {
                    if (dialogContext.mounted) {
                      // ✅ dialogContext 사용
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('오류: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text('입고'),
              ),
            ],
          );
        },
      ),
    );
  }
}
