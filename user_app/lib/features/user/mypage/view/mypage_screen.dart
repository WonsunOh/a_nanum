// user_app/lib/features/user/mypage/view/mypage_screen.dart (전체 교체)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/provider/auth_provider.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../../../providers/user_provider.dart'; // userProvider import

class MyPageScreen extends ConsumerWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // ⭐️ 1. Supabase의 인증 상태 변화를 '감시'하는 리스너 추가
    ref.listen(authStateChangeProvider, (previous, next) {
      // 로그아웃 이벤트(signedOut)가 감지되면
      if (next.value?.event == AuthChangeEvent.signedOut) {
        // 즉시 로그인 화면으로 이동시킵니다.
        context.go('/login');
      }
    });
    final userProfileAsync = ref.watch(userProvider);

    // 마이페이지 메뉴 데이터
    final menuItems = [
      _MyPageMenuItem(icon: Icons.favorite_border, title: '찜한 목록', route: '/shop/mypage/wishlist'),
      _MyPageMenuItem(icon: Icons.list_alt, title: '주문 내역', route: '/shop/mypage/orders'),
      _MyPageMenuItem(icon: Icons.edit_note, title: '내가 쓴 글', route: '/shop/mypage/posts'),
      _MyPageMenuItem(icon: Icons.logout, title: '로그아웃', onTap: () {
        ref.read(authViewModelProvider.notifier).signOut();
      }),
    ];

    return userProfileAsync.when(
      data: (profile) {
        return LayoutBuilder(
          builder: (context, constraints) {
            bool isWideScreen = constraints.maxWidth > 600;

            return SingleChildScrollView(
              padding: EdgeInsets.all(isWideScreen ? 32 : 16),
              child: Column(
                children: [
                  // 사용자 프로필 정보
                  Row(
                    children: [
                      const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 50)),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(profile?.nickname ?? '닉네임 없음', style: Theme.of(context).textTheme.titleLarge),
                          Text(profile?.fullName ?? '사용자', style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 48),

                  // ⭐️ 반응형 메뉴 그리드/리스트
                  isWideScreen
                      ? GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.5,
                          ),
                          itemCount: menuItems.length,
                          itemBuilder: (context, index) {
                            final item = menuItems[index];
                            return _buildMenuCard(context, item);
                          },
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: menuItems.length,
                          itemBuilder: (context, index) {
                            final item = menuItems[index];
                            return _buildMenuListTile(context, item);
                          },
                          separatorBuilder: (_, __) => const Divider(),
                        )
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => const Center(child: Text('프로필 정보를 불러올 수 없습니다.')),
    );
  }

  // 웹용 메뉴 카드
  Widget _buildMenuCard(BuildContext context, _MyPageMenuItem item) {
    return Card(
      child: InkWell(
        onTap: item.onTap ?? () => context.go(item.route!),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(item.title, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }

  // 모바일용 메뉴 리스트 타일
  Widget _buildMenuListTile(BuildContext context, _MyPageMenuItem item) {
    return ListTile(
      leading: Icon(item.icon),
      title: Text(item.title),
      trailing: const Icon(Icons.chevron_right),
      onTap: item.onTap ?? () => context.go(item.route!),
    );
  }
}

// 마이페이지 메뉴 아이템을 위한 작은 헬퍼 클래스
class _MyPageMenuItem {
  final IconData icon;
  final String title;
  final String? route;
  final VoidCallback? onTap;

  _MyPageMenuItem({required this.icon, required this.title, this.route, this.onTap});
}