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
import '../features/shop/view/product_detail_screen.dart';
import '../features/shop/view/shop_screen.dart';
import '../features/user/auth/view/login_screen.dart';
import '../features/user/auth/view/signup_screen.dart';
import '../features/user/auth/view/splash_screen.dart';
import '../features/user/mypage/view/mypage_screen.dart';

enum AppRoute {
  splash,
  login,
  signup,
  shop,
  groupBuy,
  groupBuyDetail,
  propose,
  mypage
}

final routerProvider = Provider<GoRouter>((ref) {
  final supabase = Supabase.instance.client;

  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen()),
      GoRoute(
          path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
          path: '/signup', builder: (context, state) => const SignUpScreen()),
      GoRoute(
          path: '/shop', builder: (context, state) => const ShopScreen(),
          // ⭐️ 2. /shop 경로 안에 하위 경로를 추가합니다.
        routes: [
          GoRoute( path: '/cart', builder: (context, state) => const CartScreen(),
          routes: [
              GoRoute(
                path: 'checkout', // 최종 경로: /shop/cart/checkout
                builder: (context, state) => const CheckoutScreen(),
              ),
            ],
          ),
            
          GoRoute( path: '/mypage', builder: (context, state) => const MyPageScreen()),
          GoRoute(
            path: ':productId', // 예: /shop/1, /shop/2 등
            builder: (context, state) {
              // 경로에서 productId를 추출하여 숫자로 변환합니다.
              final productId = int.parse(state.pathParameters['productId']!);
              return ProductDetailScreen(productId: productId);
            },
          ),
          
        ],
          ), // ⭐️ 새로운 홈
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
      GoRoute( path: '/propose', builder: (context, state) => const ProposeGroupBuyScreen()),
      
      
    ],
    refreshListenable: GoRouterRefreshStream(supabase.auth.onAuthStateChange),
    redirect: (BuildContext context, GoRouterState state) {
      final session = supabase.auth.currentSession;
      final isAuthenticated = session != null;
      final isAtSplash = state.matchedLocation == '/splash';

      // 규칙 1: 스플래시에서는 무조건 '/shop'으로 이동
      if (isAtSplash) {
        return '/shop';
      }
      
      final isGoingToAuthFlow =
          state.matchedLocation == '/login' || state.matchedLocation == '/signup';

      // 규칙 2: 로그인 사용자가 로그인/가입 페이지로 가면 '/shop'으로 이동
      if (isAuthenticated && isGoingToAuthFlow) {
        return '/shop';
      }

      // 규칙 3: 로그인이 필요한 페이지 보호
      final authRequiredRoutes = ['/propose', '/mypage'];
      if (!isAuthenticated && authRequiredRoutes.contains(state.matchedLocation)) {
        return '/login';
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