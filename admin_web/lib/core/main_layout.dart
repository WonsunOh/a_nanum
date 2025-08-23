// admin_web/lib/core/main_layout.dart (전체 교체)

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'admin_menu_item.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final List<AdminMenuItem> menuItems = [
    AdminMenuItem(
      title: '대시보드',
      icon: Icons.dashboard_outlined,
      route: '/dashboard',
    ),
    AdminMenuItem(
      title: '쇼핑몰 관리',
      icon: Icons.storefront_outlined,
      children: [
        AdminMenuItem(title: '상품 관리', route: '/shop/products'),
        AdminMenuItem(title: '카테고리 관리', route: '/shop/categories'),
      ],
    ),
    AdminMenuItem(
      title: '공동구매 관리',
      icon: Icons.group_work_outlined,
      children: [
        AdminMenuItem(title: '공동구매 현황', route: '/group-buy'),
        AdminMenuItem(title: '주문 관리', route: '/orders'),
      ],
    ),
    AdminMenuItem(
      title: '회원 관리',
      icon: Icons.people_outline,
      route: '/users',
    ),
    AdminMenuItem(
      title: '고객 지원',
      icon: Icons.support_agent_outlined,
      children: [
        AdminMenuItem(title: '문의 내역', route: '/cs/inquiries'),
        AdminMenuItem(title: '답변 템플릿', route: '/cs/templates'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // ⭐️ 1. 중복 메뉴 방지 로직을 다시 추가했습니다.
    final hasOuterLayout =
        context.findAncestorWidgetOfExactType<MainLayout>() != null;

    // 만약 바깥에 이미 MainLayout이 있다면, 메뉴 없이 내용물(child)만 보여줍니다.
    if (hasOuterLayout) {
      return widget.child;
    }
    
    // ⭐️ 2. 나머지 코드는 접이식 메뉴 기능을 그대로 유지합니다.
    final currentRoute = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 250,
            child: Drawer(
              elevation: 1.0,
              child: ListView.builder(
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  if (item.children.isEmpty) {
                    return ListTile(
                      leading: Icon(item.icon),
                      title: Text(item.title),
                      selected: currentRoute == item.route,
                      onTap: () => context.go(item.route),
                    );
                  } else {
                    bool isExpanded = item.children
                        .any((child) => currentRoute.startsWith(child.route));
                    return ExpansionTile(
                      key: PageStorageKey(item.title),
                      initiallyExpanded: isExpanded,
                      leading: Icon(item.icon),
                      title: Text(item.title),
                      children: item.children.map((child) {
                        return ListTile(
                          title: Text(child.title),
                          selected: currentRoute == child.route,
                          onTap: () => context.go(child.route),
                          contentPadding: const EdgeInsets.only(left: 40.0),
                        );
                      }).toList(),
                    );
                  }
                },
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: PageStorage(
            key: PageStorageKey(GoRouterState.of(context).matchedLocation),
            bucket: PageStorageBucket(),
            child: widget.child,
          ),
        ),
      ],
      ),
    );
  }
}