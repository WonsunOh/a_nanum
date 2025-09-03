// user_app/lib/core/router.dart (전체 교체)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/cart/view/cart_screen.dart';
import '../features/commiunity/proposal/view/propose_group_buy_screen.dart';
import '../features/group_buy/view/group_buy_detail_screen.dart';
import '../features/group_buy/view/group_buy_list_screen.dart';
import '../features/order/view/checkout_screen.dart';
import '../features/order/view/order_history_screen.dart';
import '../features/payment/views/portone_web_html_screen.dart';
import '../features/post/view/my_posts_screen.dart';
import '../features/shop/view/product_detail_screen.dart';
import '../features/shop/view/shop_screen.dart';
import '../features/user/auth/view/login_screen.dart';
import '../features/user/auth/view/signup_screen.dart';
import '../features/user/auth/view/splash_screen.dart';
import '../features/user/mypage/view/mypage_screen.dart';
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
}

final routerProvider = Provider<GoRouter>((ref) {
  final supabase = Supabase.instance.client;

  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute( path: '/splash', builder: (context, state) => const SplashScreen(), ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),

      // ⭐️ 새로운 홈
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/shop',
            builder: (context, state) => const ShopScreen(),
            routes: [
              GoRoute(
                path: 'cart',
                builder: (context, state) => const CartScreen(),
                routes: [
                  GoRoute(
                    path: 'checkout', // 최종 경로: /shop/cart/checkout
                    builder: (context, state) => const CheckoutScreen(),
                  ),
                ],
              ),
              GoRoute(
                path: 'mypage',
                builder: (context, state) => const MyPageScreen(),
                routes: [
                  GoRoute(
                    path: 'wishlist', // 최종 경로: /shop/mypage/wishlist
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
                ],
              ),

              GoRoute(
  path: 'cart',
  builder: (context, state) => const CartScreen(),
  routes: [
    GoRoute(
      path: 'checkout', // 최종 경로: /shop/cart/checkout
      builder: (context, state) => const CheckoutScreen(),
      routes: [
        // ⭐️ 결제 화면 경로 추가
        GoRoute(
          path: 'payment', // 최종 경로: /shop/cart/checkout/payment
          builder: (context, state) {
            // 쿼리 파라미터에서 결제 정보 가져오기
            final totalAmount = int.parse(state.uri.queryParameters['totalAmount'] ?? '0');
            final orderName = state.uri.queryParameters['orderName'] ?? '';
            final customerName = state.uri.queryParameters['customerName'] ?? '';
            final customerPhone = state.uri.queryParameters['customerPhone'] ?? '';
            final customerAddress = state.uri.queryParameters['customerAddress'] ?? '';
            final customerEmail = state.uri.queryParameters['customerEmail'] ?? '';
            
            return PortOneWebHtmlScreen(
              totalAmount: totalAmount,
              orderName: orderName,
              customerName: customerName,
              customerPhone: customerPhone,
              customerAddress: customerAddress, 
              customerEmail: customerEmail,
              // orderItems: const [], // 필요하면 별도 방식으로 전달
            );
          },
        ),
      ],
    ),
  ],
),
              GoRoute(
                path: ':productId',
                builder: (context, state) {
                  // 'cart', 'mypage'가 아닌 경우에만 상품 ID로 간주
                  if (state.pathParameters['productId'] != 'cart' &&
                      state.pathParameters['productId'] != 'mypage') {
                    final productId = int.parse(
                      state.pathParameters['productId']!,
                    );
                    return ProductDetailScreen(productId: productId);
                  }
                  // 일치하는 경로가 없을 경우 에러 페이지 또는 홈으로 리디렉션 (옵션)
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: '/group-buy', // ➡️ 기존 '/home'에서 변경
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
      GoRoute(
        path: '/propose',
        builder: (context, state) => const ProposeGroupBuyScreen(),
      ),
    ],

    refreshListenable: GoRouterRefreshStream(supabase.auth.onAuthStateChange),
    redirect: (BuildContext context, GoRouterState state) {
      final session = supabase.auth.currentSession;
      final isAuthenticated = session != null;
      final isAtSplash = state.matchedLocation == '/splash';
      final isGoingToLogin = state.matchedLocation == '/login';

      // ⭐️ 규칙 1: 스플래시 화면에 있다면, 무조건 '/shop'으로 이동시킨다.
      if (isAtSplash) {
        return '/shop';
      }

            // 로그인이 필요한 페이지 목록
      final authRequiredRoutes = ['/shop/mypage', '/shop/cart', '/shop/cart/checkout'];

// 로그인 안 된 사용자가 보호된 경로로 가려고 하면 -> 로그인 페이지로
      if (!isAuthenticated && authRequiredRoutes.contains(state.matchedLocation)) {
        return '/login?from=${state.matchedLocation}';
      }
      
      // 로그인 된 사용자가 로그인 페이지로 가려고 하면 -> 쇼핑몰 홈으로
      if (isAuthenticated && isGoingToLogin) {
        return '/shop';
      }

      return null;
    },
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<AuthState> stream) {
    notifyListeners();
    stream.asBroadcastStream().listen((_) => notifyListeners());
  }
}
