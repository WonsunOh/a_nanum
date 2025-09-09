// nanum_admin/lib/core/main_layout.dart (원본 구조 유지 + 에러만 수정)

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
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

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
      children: [AdminMenuItem(title: '공동구매 현황', route: '/group-buy')],
    ),
    AdminMenuItem(
      title: '주문 관리',
      icon: Icons.receipt_long_outlined,
      children: [
        AdminMenuItem(title: '쇼핑몰 주문내역', route: '/orders/shop'),
        AdminMenuItem(title: '공동구매 주문내역', route: '/orders/group-buy'),
      ],
    ),
    AdminMenuItem(title: '회원 관리', icon: Icons.people_outline, route: '/users'),
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
    // ✅ 기존 Provider 사용하되 에러 처리만 개선
    ref.listen(authStateChangeProvider, (previous, next) {
      // ✅ null 안전성 처리 추가
      next.whenData((authState) {
        if (authState.event == AuthChangeEvent.signedOut) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.go('/login');
            }
          });
        }
      });
    });

    // 중복 메뉴 방지 로직
    final hasOuterLayout =
        context.findAncestorWidgetOfExactType<MainLayout>() != null;
    if (hasOuterLayout) {
      return widget.child;
    }

    // ✅ 원본 구조 그대로 유지
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
                  // 햄버거 버튼
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 8, 0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: Icon(
                          _isMenuExpanded ? Icons.menu_open : Icons.menu,
                        ),
                        tooltip: _isMenuExpanded ? '메뉴 접기' : '메뉴 펼치기',
                        onPressed: () {
                          setState(() {
                            _isMenuExpanded = !_isMenuExpanded;
                          });
                        },
                      ),
                    ),
                  ),

                  // 로고/제목
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.admin_panel_settings,
                          size: _isMenuExpanded ? 40 : 30,
                          color: Colors.blue,
                        ),
                        if (_isMenuExpanded) ...[
                          const SizedBox(height: 8),
                          const Text(
                            '나눔 관리자',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const Divider(),

                  // 메뉴 아이템들
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: menuItems.map((item) {
                        // ✅ null 안전성 문제 해결
                        final bool isSelected = item.children.isNotEmpty
                            ? item.children.any(
                                (child) => currentRoute.startsWith(child.route),
                              )
                            : currentRoute.startsWith(item.route);

                        return item.children.isNotEmpty
                            ? ExpansionTile(
                                key: ValueKey(item.title),
                                leading: Icon(
                                  item.icon,
                                  color: isSelected
                                      ? Colors.blue
                                      : Colors.grey[600],
                                ),
                                title: _isMenuExpanded
                                    ? Text(
                                        item.title,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.blue
                                              : Colors.grey[700],
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                                children: item.children.map((child) {
                                  final childSelected = currentRoute.startsWith(
                                    child.route,
                                  );
                                  return ListTile(
                                    contentPadding: const EdgeInsets.only(
                                      left: 72,
                                      right: 16,
                                    ),
                                    title: _isMenuExpanded
                                        ? Text(
                                            child.title,
                                            style: TextStyle(
                                              color: childSelected
                                                  ? Colors.blue
                                                  : Colors.grey[600],
                                              fontWeight: childSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                    onTap: () => context.go(child.route),
                                  );
                                }).toList(),
                                onExpansionChanged: (expanded) {
                                  if (expanded && !_isMenuExpanded) {
                                    setState(() => _isMenuExpanded = true);
                                  }
                                },
                              )
                            : ListTile(
                                leading: Icon(
                                  item.icon,
                                  color: isSelected
                                      ? Colors.blue
                                      : Colors.grey[600],
                                ),
                                title: _isMenuExpanded
                                    ? Text(
                                        item.title,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.blue
                                              : Colors.grey[700],
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                                selected: isSelected,
                                selectedTileColor: Colors.blue.withValues(
                                  alpha: 0.1,
                                ),
                                onTap: () => context.go(item.route),
                              );
                      }).toList(),
                    ),
                  ),

                  const Divider(),

                  // 로그아웃 버튼
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: _isMenuExpanded
                        ? const Text('로그아웃')
                        : const SizedBox.shrink(), // ✅ null 대신 빈 위젯
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

          // ✅ 원본 구조 그대로 유지
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
