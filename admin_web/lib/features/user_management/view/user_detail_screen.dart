import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/main_layout.dart';
import '../viewmodel/user_viewmodel.dart';

class UserDetailScreen extends ConsumerWidget {
  final String userId;
  const UserDetailScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDetailAsync = ref.watch(userDetailProvider(userId));

    return MainLayout(
      child: userDetailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('사용자 정보 로딩 실패: $e')),
        data: (detail) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // 사용자 프로필 정보
              Text(detail.profile.username, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(detail.profile.email),
              Text('가입일: ${DateFormat('yyyy-MM-dd').format(detail.profile.createdAt)}'),
              const Divider(height: 48),

              // 참여한 공구 목록
              Text('참여 내역 (${detail.participations.length}건)', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              ...detail.participations.map((p) => Card(
                child: ListTile(
                  leading: p.productImageUrl != null
                      ? Image.network(p.productImageUrl!, width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.image_not_supported),
                  title: Text(p.productName),
                  subtitle: Text('수량: ${p.quantity}개 | 상태: ${p.status}'),
                  trailing: Text(DateFormat('yyyy-MM-dd').format(p.joinedAt)),
                ),
              )),
            ],
          );
        },
      ),
    );
  }
}