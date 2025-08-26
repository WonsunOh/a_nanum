// user_app/lib/core/widgets/main_layout.dart (새 파일)

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => context.go('/shop'), // 로고를 누르면 홈으로 이동
          child: const Text('나눔 스토어'),
        ),
        actions: [
          IconButton(
            onPressed: () => context.go('/shop/cart'),
            icon: const Icon(Icons.shopping_cart_outlined),
            tooltip: '장바구니',
          ),
          IconButton(
            onPressed: () => context.go('/group-buy'),
            icon: const Icon(Icons.group_work_outlined),
            tooltip: '공동구매 보러가기',
          ),
          IconButton(
            onPressed: () => context.go('/shop/mypage'),
            icon: const Icon(Icons.person_outline),
            tooltip: '마이페이지',
          ),
        ],
      ),
      // ⭐️ 화면 중앙에 최대 너비를 가진 영역을 만들고, 그 안에 페이지 내용을 표시합니다.
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: child,
        ),
      ),
    );
  }
}