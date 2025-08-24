// user_app/lib/features/user/mypage/view/mypage_screen.dart (전체 교체)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // ⭐️ Supabase import

// ⭐️ 새로 만든 Provider와 기존 ViewModel을 import 합니다.
import '../../auth/provider/auth_provider.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';

class MyPageScreen extends ConsumerWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ⭐️ ref.listen을 사용해 인증 상태 변화를 감시합니다.
    ref.listen(authStateChangeProvider, (previous, next) {
      // 로그아웃 이벤트(signedOut)가 감지되면
      if (next.value?.event == AuthChangeEvent.signedOut) {
        // 즉시 로그인 화면으로 이동시킵니다.
        context.go('/login');
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: '홈으로 가기',
            onPressed: () {
              context.go('/shop');
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text('사용자 이름'),
            accountEmail: Text('user@example.com'),
            currentAccountPicture: CircleAvatar(
              child: Icon(Icons.person, size: 50),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: const Text('주문 내역'),
            onTap: () { /* TODO: 주문 내역 페이지 */ },
          ),
          ListTile(
            leading: const Icon(Icons.edit_note),
            title: const Text('내가 쓴 글'),
            onTap: () { /* TODO: 내가 쓴 글 페이지 */ },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('로그아웃'),
            onTap: () {
              // ViewModel의 signOut 메서드를 호출합니다.
              ref.read(authViewModelProvider.notifier).signOut();
            },
          ),
        ],
      ),
    );
  }
}