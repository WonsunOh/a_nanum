import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/main_layout.dart';
import '../../../data/models/managed_group_buy_model.dart';
import '../viewmodel/group_buy_management_viewmodel.dart';

class GroupBuyManagementScreen extends ConsumerWidget {
  const GroupBuyManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupBuysAsync = ref.watch(groupBuyManagementViewModelProvider);
    final viewModel = ref.read(groupBuyManagementViewModelProvider.notifier);

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
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_note),
                                tooltip: '상태 변경',
                                onPressed: () {
                                  _showStatusEditDialog(context, viewModel, gb);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: '삭제',
                                onPressed: () async {
                                  final confirm = await _showDeleteConfirmDialog(context);
                                  if (confirm == true) await viewModel.delete(gb.id);
                                },
                              ),
                            ],
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
  void _showStatusEditDialog(BuildContext context, GroupBuyManagementViewModel viewModel, ManagedGroupBuy gb) {
    // 💡 1. 영어 DB값과 한글 UI 텍스트를 짝지어주는 Map을 만듭니다.
    final Map<String, String> statusMap = {
      'recruiting': '모집 중',
      'success': '모집 성공',
      'failed': '모집 실패',
      'preparing': '상품 준비 중',
      'shipped': '배송 중',
      'completed': '배송 완료',
    };
    String selectedStatus = gb.status;
    showDialog(
      context: context,
      builder: (context) {
        // 💡 StatefulBuilder를 사용하여 다이얼로그 내부의 상태를 관리합니다.
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Consumer(
              builder: (context, ref, child) {
                final viewModelState = ref.watch(groupBuyManagementViewModelProvider);

                return AlertDialog(
                  title: Text('${gb.productName} 상태 변경', style: Theme.of(context).textTheme.titleLarge),
                  content: DropdownButton<String>(
                    value: selectedStatus,
                    isExpanded: true,
                    items: statusMap.keys.map((String key) {
                      return DropdownMenuItem<String>(
                        value: key,
                        child: Text(statusMap[key]!),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        // 💡 setState를 호출하여 드롭다운의 표시값을 업데이트합니다.
                        setState(() {
                          selectedStatus = newValue;
                        });
                      }
                    },
                  ),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('취소')),
                          ElevatedButton(
                onPressed: viewModelState.isLoading ? null : () async {
                  await viewModel.updateStatus(gb.id, selectedStatus);
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: viewModelState.isLoading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                          : const Text('저장'),
                          ),
                        ],
                      );
              }
            );
          },
        );
      },
    );
  }

  /// ## 삭제 확인 다이얼로그
  /// 사용자에게 삭제 여부를 재확인하고, 그 결과를 bool? 타입으로 반환합니다.
  Future<bool?> _showDeleteConfirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('공구 삭제'),
        content: const Text('정말로 이 공구를 삭제하시겠습니까? 관련된 참여 내역이 모두 사라지며, 복구할 수 없습니다.'),
        actions: [
          // '아니오' 버튼: 누르면 false를 반환하며 다이얼로그를 닫습니다.
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('아니오'),
          ),
          // '삭제' 버튼: 누르면 true를 반환하며 다이얼로그를 닫습니다.
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}