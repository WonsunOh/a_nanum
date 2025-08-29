// admin_web/lib/core/main_layout.dart (전체 교체)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/auth/provider/auth_provider.dart';
import '../features/auth/viewmodel/auth_viewmodel.dart';
import 'admin_menu_item.dart';

class MainLayout extends ConsumerStatefulWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  // ⭐️ 3. State -> ConsumerState로 변경
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

// ⭐️ 4. State -> ConsumerState로 변경
class _MainLayoutState extends ConsumerState<MainLayout> {

  bool _isMenuExpanded = true;
  
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
         AdminMenuItem(title: '할인상품 관리', route: '/shop/discount_products'),
          AdminMenuItem(title: '프로모션 관리', route: '/shop/promotions'),
        AdminMenuItem(title: '카테고리 관리', route: '/shop/categories'),
      ],
    ),
    AdminMenuItem(
      title: '공동구매 관리',
      icon: Icons.group_work_outlined,
      children: [
        AdminMenuItem(title: '공동구매 현황', route: '/group-buy'),
      ],
    ),
    AdminMenuItem(
      title: '주문 관리',
      icon: Icons.receipt_long_outlined, // 새로운 아이콘
      children: [
        AdminMenuItem(title: '쇼핑몰 주문내역', route: '/orders/shop'),
        AdminMenuItem(title: '공동구매 주문내역', route: '/orders/group-buy'),
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
    AdminMenuItem(
    title: '환경설정',
    icon: Icons.settings_outlined,
    route: '/settings',
  ),
  ];

  @override
  Widget build(BuildContext context) {

    ref.listen(authStateChangeProvider, (previous, next) {
      // next.value를 사용하여 실제 AuthState 데이터에 접근합니다.
      // next.value?.event를 사용하여 안전하게 'event' 속성에 접근합니다.
      if (next.value?.event == AuthChangeEvent.signedOut) {
        context.go('/login');
      }
    });
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
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _isMenuExpanded ? 250 : 80,
            child: Drawer(
              elevation: 1.0,
              child: Column(
                children: [
                  // --- 💡 여기가 핵심 수정 부분입니다! ---
                  // 햄버거 버튼을 Drawer 내부의 오른쪽 상단으로 이동
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 8, 0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: Icon(
                            _isMenuExpanded ? Icons.menu_open : Icons.menu),
                        tooltip: _isMenuExpanded ? '메뉴 축소' : '메뉴 확장',
                        onPressed: () {
                          setState(() {
                            _isMenuExpanded = !_isMenuExpanded;
                          });
                        },
                      ),
                    ),
                  ),
                  // ------------------------------------

                  Expanded(
                    child: ListView.builder(
                      itemCount: menuItems.length,
                      itemBuilder: (context, index) {
                        final item = menuItems[index];
                        if (_isMenuExpanded) {
                          if (item.children.isEmpty) {
                            return ListTile(
                              leading: Icon(item.icon),
                              title: Text(item.title),
                              selected: currentRoute == item.route,
                              onTap: () => context.go(item.route),
                            );
                          } else {
                            bool isExpanded = item.children.any((child) =>
                                currentRoute.startsWith(child.route));
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
                                  contentPadding:
                                      const EdgeInsets.only(left: 40.0),
                                );
                              }).toList(),
                            );
                          }
                        } else {
                          // 축소 상태 UI
                          return Tooltip(
                            message: item.title,
                            child: ListTile(
                              leading: Icon(item.icon),
                              selected: GoRouterState.of(context)
                                  .matchedLocation
                                  .startsWith(item.route),
                              onTap: () {
                                if (item.children.isNotEmpty) {
                                  setState(() => _isMenuExpanded = true);
                                } else {
                                  context.go(item.route);
                                }
                              },
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: _isMenuExpanded ? const Text('로그아웃') : null,
                    onTap: () {
                      ref.read(authViewModelProvider.notifier).signOut();
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          // --- 💡 여기도 수정되었습니다! ---
          // 불필요한 Column을 제거하고 widget.child가 바로 공간을 차지하도록 변경
          Expanded(
            child: PageStorage(
              key: PageStorageKey(GoRouterState.of(context).matchedLocation),
              bucket: PageStorageBucket(),
              child: widget.child,
            ),
          ),
          // ---------------------------
        ],
      ),
    );
  }
}