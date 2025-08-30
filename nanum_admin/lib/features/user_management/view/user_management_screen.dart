import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/main_layout.dart';
import '../../../data/models/app_user_model.dart';
import '../viewmodel/user_viewmodel.dart';

class UserManagementScreen extends ConsumerWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(userViewModelProvider);

    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('회원 관리', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            // 검색창
            TextField(
              decoration: const InputDecoration(
                hintText: '이메일 또는 이름으로 검색...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // 입력값이 변경될 때마다 검색어 Provider의 상태를 업데이트
                ref.read(userSearchQueryProvider.notifier).setSearchQuery(value);
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: usersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Text('Error: $e'),
                data: (users) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('이름')),
                        DataColumn(label: Text('이메일')),
                        DataColumn(label: Text('가입일')),
                        DataColumn(label: Text('관리')),
                      ],
                      rows: users.map((user) {
                        return DataRow(
                          // 💡 onSelectChanged를 사용하여 행 클릭 이벤트 처리
    onSelectChanged: (isSelected) {
      if (isSelected ?? false) {
        context.go('/users/${user.id}');
      }
    },
                          cells: [
                          DataCell(Text(user.username)),
                          DataCell(Text(user.email)),
                          DataCell(Text(DateFormat('yyyy-MM-dd').format(user.createdAt))),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.visibility),
                                  onPressed: () { /* 상세 정보 보기 */ },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.military_tech), // 레벨 아이콘
                                  tooltip: '레벨 조정',
                                  onPressed: () {
                                    _showEditLevelDialog(context, ref, user);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 💡 레벨 조정 다이얼로그를 보여주는 함수
  void _showEditLevelDialog(BuildContext context, WidgetRef ref, AppUser user) {
    final levelController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${user.username} 레벨 조정'),
        content: TextField(
          controller: levelController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: '새로운 레벨 입력'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('취소')),
          ElevatedButton(
            onPressed: () async {
              final newLevel = int.tryParse(levelController.text);
              if (newLevel != null) {
                await ref.read(userViewModelProvider.notifier).updateUserLevel(user.id, newLevel);
                if (context.mounted) Navigator.of(context).pop();
              }
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }
}