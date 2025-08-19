import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/main_layout.dart';
import '../viewmodel/group_buy_management_viewmodel.dart';

class GroupBuyManagementScreen extends ConsumerWidget {
  const GroupBuyManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupBuysAsync = ref.watch(groupBuyManagementViewModelProvider);

    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('개설된 공구 관리', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Expanded(
              child: groupBuysAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Text('Error: $e'),
                data: (groupBuys) => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('상품명')),
                      DataColumn(label: Text('공구장')),
                      DataColumn(label: Text('모집 현황')),
                      DataColumn(label: Text('상태')),
                      DataColumn(label: Text('관리')),
                    ],
                    rows: groupBuys.map((gb) {
                      return DataRow(cells: [
                        DataCell(Text(gb.productName)),
                        DataCell(Text(gb.hostName)),
                        DataCell(Text('${gb.currentParticipants} / ${gb.targetParticipants}')),
                        DataCell(Text(gb.status)),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.edit_note),
                            tooltip: '상태 변경',
                            onPressed: () { /* TODO: 상태 변경 로직 */ },
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}