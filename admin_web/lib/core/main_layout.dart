import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'admin_menu_item.dart';

// 💡 전체 메뉴 구조를 데이터로 정의
final List<AdminMenuItem> menuItems = [
  const AdminMenuItem(title: '대시보드', icon: Icons.dashboard, route: '/dashboard'),
  const AdminMenuItem(
    title: '상품 관리',
    icon: Icons.shopping_bag,
    route: '/products',
    subItems: [
      AdminMenuItem(title: '카테고리 관리', icon: Icons.category, route: '/categories'),
      AdminMenuItem(title: '공구 관리', icon: Icons.groups, route: '/group-buys'),
    ],
  ),
  const AdminMenuItem(title: '주문 관리', icon: Icons.receipt_long, route: '/orders'),
  const AdminMenuItem(title: '회원 관리', icon: Icons.people_alt, route: '/users'),
  const AdminMenuItem(
    title: '고객 지원',
    icon: Icons.support_agent,
    route: '/inquiries',
    subItems: [
      AdminMenuItem(title: '답변 템플릿', icon: Icons.feed, route: '/inquiries/templates'),
    ],
  ),
];

class MainLayout extends StatelessWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});


  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.toString();


    // 1. 현재 경로가 어떤 최상위 메뉴에 속하는지 찾습니다.
    AdminMenuItem? topLevelActiveItem;
    for (final item in menuItems) {
      if (currentRoute.startsWith(item.route)) {
        topLevelActiveItem = item;
        break;
      }
      // 하위 메뉴까지 확인
      for (final subItem in item.subItems) {
        if (currentRoute.startsWith(subItem.route)) {
          topLevelActiveItem = item;
          break;
        }
      }
      if (topLevelActiveItem != null) break;
    }

    // 2. 현재 화면에 표시될 최종 메뉴 리스트를 구성합니다.
    final List<AdminMenuItem> visibleMenuItems = [];
    for (final item in menuItems) {
      visibleMenuItems.add(item);
      // 현재 활성화된 최상위 메뉴의 하위 메뉴들만 리스트에 추가합니다.
      if (topLevelActiveItem != null && item.route == topLevelActiveItem.route) {
        visibleMenuItems.addAll(item.subItems);
      }
    }

    // 3. 최종 메뉴 리스트에서 현재 선택된 인덱스를 찾습니다.
    int selectedIndex = visibleMenuItems.indexWhere((item) => item.route == currentRoute);
    if (selectedIndex == -1) {
      // 만약 정확히 일치하는 경로가 없다면(예: /products), 상위 메뉴를 선택된 것으로 처리
      selectedIndex = visibleMenuItems.indexWhere((item) => item.route == topLevelActiveItem?.route);
      if (selectedIndex == -1) selectedIndex = 0;
    }
    
    // 4. UI를 그립니다. (이하 로직은 이전과 거의 동일)
    final destinations = visibleMenuItems.map((item) {
      bool isSubItem = menuItems.any((mainItem) => mainItem.subItems.contains(item));
      return NavigationRailDestination(
        icon: isSubItem
            ? Padding(padding: const EdgeInsets.only(left: 16.0), child: Icon(item.icon, size: 20))
            : Icon(item.icon),
        label: isSubItem ? Text('  ${item.title}') : Text(item.title),
      );
    }).toList();

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: true,
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              // 4. 최종 메뉴 리스트의 인덱스를 가지고 직접 경로로 이동합니다. (가장 단순하고 확실한 방법)
              context.go(visibleMenuItems[index].route);
            },
            destinations: destinations,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}