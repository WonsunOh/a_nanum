// nanum_admin/lib/core/main_layout.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../features/auth/provider/auth_provider.dart';
import '../features/auth/viewmodel/auth_viewmodel.dart';
import 'admin_menu_item.dart';
import 'providers/inactivity_timer_provider.dart';

class MainLayout extends ConsumerStatefulWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  bool _isMenuExpanded = true;

  @override
  void initState() {
    super.initState();
    
    // ✅ 초기 타이머 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(inactivityTimerProvider.notifier).resetTimer();
        debugPrint('✅ Inactivity timer started');
      }
    });
  }

  Future<void> _openShoppingMall() async {
    final Uri url = Uri.parse('http://localhost:6186');
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('쇼핑몰 페이지를 열 수 없습니다.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
        AdminMenuItem(title: '재고 관리', route: '/shop/inventory'),
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
    // ✅ 비활성 로그아웃 감지 - previous와 next를 비교
    ref.listen(inactivityLogoutTriggerProvider, (previous, next) {
      // ✅ Provider가 새로 생성되었을 때 (이전 값이 없을 때) 로그아웃 실행
      if (previous != null && mounted) {
        debugPrint('🔔 Logout listener triggered: previous=$previous, next=$next');
        _handleInactivityLogout();
      }
    });

    // 기존 인증 상태 변경 감지
    ref.listen(authStateChangeProvider, (previous, next) {
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

    final hasOuterLayout =
        context.findAncestorWidgetOfExactType<MainLayout>() != null;
    if (hasOuterLayout) {
      return widget.child;
    }

    final currentRoute = GoRouterState.of(context).matchedLocation;

    return Listener(
      onPointerDown: (_) => _onUserActivity(),
      onPointerMove: (_) => _onUserActivity(),
      onPointerHover: (_) => _onUserActivity(),
      child: Scaffold(
        body: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _isMenuExpanded ? 250 : 80,
              child: Drawer(
                elevation: 1.0,
                child: Column(
                  children: [
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

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: _isMenuExpanded
                          ? ElevatedButton.icon(
                              onPressed: _openShoppingMall,
                              icon: const Icon(Icons.storefront, size: 18),
                              label: const Text('쇼핑몰 바로가기'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 44),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            )
                          : IconButton(
                              onPressed: _openShoppingMall,
                              icon: const Icon(Icons.storefront),
                              tooltip: '쇼핑몰 바로가기',
                              color: Colors.green,
                              iconSize: 28,
                            ),
                    ),
      
                    const Divider(),
      
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: menuItems.map((item) {
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
      
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: _isMenuExpanded
                          ? const Text('로그아웃')
                          : const SizedBox.shrink(),
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
      
            Expanded(
              child: PageStorage(
                key: PageStorageKey(GoRouterState.of(context).matchedLocation),
                bucket: PageStorageBucket(),
                child: widget.child,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 사용자 활동 감지 메서드
  void _onUserActivity() {
    ref.read(inactivityTimerProvider.notifier).resetTimer();
  }

  // 비활성으로 인한 로그아웃 처리
  void _handleInactivityLogout() {
    debugPrint('🚪 Executing inactivity logout...');
    
    // 타이머 취소
    ref.read(inactivityTimerProvider.notifier).cancelTimer();
    
    // 사용자에게 알림 (로그아웃 전에 표시)
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('장시간 활동이 없어 자동으로 로그아웃되었습니다.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 5),
        ),
      );
    }
    
    // 로그아웃 실행
    ref.read(authViewModelProvider.notifier).signOut();
  }
}