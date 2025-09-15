// user_app/lib/core/router.dart (전체 교체)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/cart/view/cart_screen.dart';
import '../features/commiunity/proposal/view/propose_group_buy_screen.dart';
import '../features/group_buy/view/group_buy_detail_screen.dart';
import '../features/group_buy/view/group_buy_list_screen.dart';
import '../features/notifications/view/notification_list_screen.dart';
import '../features/notifications/view/order_cancellation_rejected_screen.dart';
import '../features/order/view/checkout_screen.dart';
import '../features/order/view/order_history_screen.dart';
import '../features/payment/views/portone_web_html_screen.dart';
import '../features/post/view/my_posts_screen.dart';
import '../features/shop/view/product_detail_screen.dart';
import '../features/shop/view/shop_screen.dart';
import '../features/user/auth/view/login_screen.dart';
import '../features/user/auth/view/signup_screen.dart';
import '../features/user/auth/view/splash_screen.dart';
import '../features/user/level_upgrade/view/level_upgrade_form_screen.dart';
import '../features/user/mypage/view/mypage_screen.dart';
import '../features/user/mypage/view/profile_edit_screen.dart';
import '../features/wishlist/view/wishlist_screen.dart';
import 'widgets/main_layout.dart';

enum AppRoute {
  splash,
  login,
  signup,
  shop,
  groupBuy,
  groupBuyDetail,
  propose,
  mypage,
  notifications,
}

final routerProvider = Provider<GoRouter>((ref) {
  final supabase = Supabase.instance.client;

  return GoRouter(
    initialLocation: '/splash',
    routes: [
      // 인증 관련 라우트 (MainLayout 없음)
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),

      // 메인 ShellRoute with MainLayout
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(
            showCategorySidebar: _shouldShowCategorySidebar(
              state.matchedLocation,
            ),
            child: child,
          );
        },
        routes: [
          // ⭐️ 알림 관련 라우트 (맨 위에 배치)
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationListScreen(),
            routes: [
              GoRoute(
                path: 'cancellation-rejected/:orderId',
                builder: (context, state) {
                  final orderId = int.parse(state.pathParameters['orderId']!);
                  return OrderCancellationRejectedScreen(orderId: orderId);
                },
              ),
            ],
          ),

          // 쇼핑 관련 라우트들
          GoRoute(
            path: '/shop',
            builder: (context, state) => const ShopScreen(),
            routes: [
              // 장바구니 관련 라우트
              GoRoute(
                path: 'cart',
                builder: (context, state) => const CartScreen(),
                routes: [
                  GoRoute(
                    path: 'checkout',
                    builder: (context, state) {
                      return CheckoutScreen();
                    },
                    routes: [
                      // 결제 라우트
                      GoRoute(
                        path: 'payment',
                        builder: (context, state) {
                          final totalAmount = int.parse(
                            state.uri.queryParameters['totalAmount'] ?? '0',
                          );
                          final orderName =
                              state.uri.queryParameters['orderName'] ?? '';
                          final customerName =
                              state.uri.queryParameters['customerName'] ?? '';
                          final customerPhone =
                              state.uri.queryParameters['customerPhone'] ?? '';
                          final customerAddress =
                              state.uri.queryParameters['customerAddress'] ??
                              '';
                          final customerEmail =
                              state.uri.queryParameters['customerEmail'] ?? '';

                          return PortOneWebHtmlScreen(
                            totalAmount: totalAmount,
                            orderName: orderName,
                            customerName: customerName,
                            customerPhone: customerPhone,
                            customerAddress: customerAddress,
                            customerEmail: customerEmail,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),

              // 마이페이지 관련 라우트
              GoRoute(
                path: 'mypage',
                builder: (context, state) => const MyPageScreen(),
                routes: [
                  GoRoute(
                    path: 'profile-edit',
                    builder: (context, state) => const ProfileEditScreen(),
                  ),
                  GoRoute(
                    path: 'wishlist',
                    builder: (context, state) => const WishlistScreen(),
                  ),
                  GoRoute(
                    path: 'orders',
                    builder: (context, state) => const OrderHistoryScreen(),
                  ),
                  GoRoute(
                    path: 'posts',
                    builder: (context, state) => const MyPostsScreen(),
                  ),
                  GoRoute(
                    path: 'level-upgrade',
                    builder: (context, state) => const LevelUpgradeFormScreen(),
                  ),
                ],
              ),

              // 상품 상세 라우트 (마지막에 배치하여 충돌 방지)
              GoRoute(
                path: ':productId',
                builder: (context, state) {
                  final productIdStr = state.pathParameters['productId']!;
                  // 예약된 라우트 이름이 아닌지 확인
                  if (productIdStr == 'cart' || productIdStr == 'mypage') {
                    return const SizedBox.shrink();
                  }

                  final productId = int.tryParse(productIdStr);
                  if (productId == null) {
                    return const SizedBox.shrink();
                  }

                  return ProductDetailScreen(productId: productId);
                },
              ),
            ],
          ),

          // 공동구매 관련 라우트 (카테고리 사이드바 없음)
          GoRoute(
            path: '/group-buy',
            builder: (context, state) => const GroupBuyListScreen(),
            routes: [
              GoRoute(
                path: 'detail/:id',
                builder: (context, state) {
                  final groupBuyId = int.parse(state.pathParameters['id']!);
                  return GroupBuyDetailScreen(groupBuyId: groupBuyId);
                },
              ),
            ],
          ),

          // 공구 제안 라우트
          GoRoute(
            path: '/propose',
            builder: (context, state) => const ProposeGroupBuyScreen(),
          ),
        ],
      ),
    ],

    refreshListenable: GoRouterRefreshStream(supabase.auth.onAuthStateChange),
    redirect: (BuildContext context, GoRouterState state) {
      final session = supabase.auth.currentSession;
      final isAuthenticated = session != null;
      final isAtSplash = state.matchedLocation == '/splash';
      final isGoingToLogin = state.matchedLocation == '/login';

      // 디버깅 강화
      print('🔍 Router Debug:');
      print('  - 요청된 경로: ${state.matchedLocation}');
      print('  - 전체 URI: ${state.uri}');
      print('  - 경로 파라미터: ${state.pathParameters}');

      // 규칙 1: 스플래시 화면에서는 항상 쇼핑몰로 리디렉션
      if (isAtSplash) {
        print('  - 스플래시에서 /shop으로 리디렉션');
        return '/shop';
      }

      // 인증이 필요한 라우트들
      final authRequiredRoutes = [
        '/shop/mypage',
        '/shop/cart',
        '/shop/cart/checkout',
        '/shop/mypage/level-upgrade',
        '/notifications', // ⭐️ 알림 페이지도 인증 필요
      ];

      // 인증되지 않은 사용자를 보호된 라우트에서 로그인으로 리디렉션
      if (!isAuthenticated &&
          authRequiredRoutes.any((route) => state.matchedLocation.startsWith(route))) {
        print('  - 인증 필요: /login으로 리디렉션');
        return '/login?from=${state.matchedLocation}';
      }

      // 로그인 페이지로 직접 이동하는 경우 리디렉션 방지
      if (isGoingToLogin) {
        if (isAuthenticated) {
          // 이미 로그인되어 있으면서 로그인 페이지로 가려는 경우만 처리
          final from = state.uri.queryParameters['from'];
          if (from != null && from.isNotEmpty) {
            try {
              final decodedFrom = Uri.decodeComponent(from);
              // 안전한 경로인지 확인
              if (decodedFrom.startsWith('/shop/') || 
                  decodedFrom.startsWith('/notifications') ||
                  decodedFrom.startsWith('/group-buy') ||
                  decodedFrom.startsWith('/propose')) {
                print('  - 로그인 후 ${decodedFrom}으로 리디렉션');
                return decodedFrom;
              }
            } catch (e) {
              // 디코딩 실패 시 기본 경로로
            }
          }
          print('  - 로그인 상태에서 /shop으로 리디렉션');
          return '/shop';
        }
        // 로그인이 안 되어 있으면 로그인 페이지로 그냥 이동
        return null;
      }

      print('  - 현재 경로: ${state.matchedLocation}');
      print('  - 인증 상태: $isAuthenticated');
      print('  - 사용자 ID: ${session?.user?.id}');
      print('  - 리디렉션 없음');
      return null;
    },
  );
});

// 카테고리 사이드바를 표시할 경로인지 확인하는 함수
bool _shouldShowCategorySidebar(String location) {
  // 쇼핑 관련 페이지에서만 카테고리 사이드바 표시
  // 단, 장바구니, 마이페이지, 결제 관련 페이지에서는 숨김
  if (!location.startsWith('/shop')) {
    return false; // 쇼핑 경로가 아니면 사이드바 숨김
  }

  final hideOnRoutes = ['/shop/cart', '/shop/mypage'];

  // 정확한 경로 매치
  for (final route in hideOnRoutes) {
    if (location == route || location.startsWith('$route/')) {
      return false;
    }
  }

  return true; // 나머지 쇼핑 경로에서는 사이드바 표시
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<AuthState> stream) {
    notifyListeners();
    stream.asBroadcastStream().listen((_) => notifyListeners());
  }
}