import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/group_buy_model.dart';
import '../features/auth/view/login_screen.dart';
import '../features/auth/view/signup_screen.dart';
import '../features/auth/view/splash_screen.dart';
import '../features/group_buy/view/group_buy_detail_screen.dart';
import '../features/group_buy/view/home_screen.dart';

// 1. Splash, Login, SignUp, Home 화면에 대한 경로를 미리 정의합니다.
enum AppRoute {
  splash,
  login,
  signup,
  home, groupBuyDetail,
}

// 2. Riverpod Provider를 사용하여 GoRouter 인스턴스를 생성합니다.
final routerProvider = Provider<GoRouter>((ref) {
  final supabase = Supabase.instance.client;

  return GoRouter(
    // 앱의 초기 경로 설정
    initialLocation: '/splash',

    
    
    // 경로 정의
    routes: [
      GoRoute(
        path: '/splash',
        name: AppRoute.splash.name,
        builder: (context, state) => const SplashScreen(), // 나중에 만들 SplashScreen
      ),
      GoRoute(
        path: '/login',
        name: AppRoute.login.name,
        builder: (context, state) => const LoginScreen(), // 나중에 만들 LoginScreen
      ),
      GoRoute(
        path: '/signup',
        name: AppRoute.signup.name,
        builder: (context, state) => const SignUpScreen(), // 나중에 만들 SignUpScreen
      ),
      GoRoute(
        path: '/home',
        name: AppRoute.home.name,
        builder: (context, state) => const HomeScreen(),
        // 💡 '/home'의 자식 경로로 상세 페이지를 추가합니다.
        routes: [
          GoRoute(
            path: 'group-buy-detail/:id', // URL에 /:id 파라미터를 받도록 설정
            name: AppRoute.groupBuyDetail.name,
            builder: (context, state) {
              // extra를 통해 전달받은 GroupBuy 객체
              final groupBuy = state.extra as GroupBuy;
              return GroupBuyDetailScreen(groupBuy: groupBuy);
            },
          ),
        ],
      ),
    ],
    
    // 3. 리디렉션 로직: 사용자의 인증 상태가 바뀔 때마다 실행됩니다.
    refreshListenable: GoRouterRefreshStream(supabase.auth.onAuthStateChange),
    redirect: (BuildContext context, GoRouterState state) {
      final session = supabase.auth.currentSession;
      final isAuth = session != null; // 로그인 되어 있으면 true

      final isSplash = state.matchedLocation == '/splash';
      if (isSplash) {
        // 스플래시 화면에서는 잠시 대기 후 상태에 따라 이동시킵니다.
        // 지금은 즉시 리디렉션 로직을 태웁니다.
        return isAuth ? '/home' : '/login';
      }

      final isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/signup';

      if (!isAuth && !isLoggingIn) {
        // 로그인 안된 상태에서 로그인/회원가입 화면이 아니면 -> 로그인 화면으로
        return '/login';
      }
      if (isAuth && isLoggingIn) {
        // 로그인 된 상태에서 로그인/회원가입 화면에 있으면 -> 홈 화면으로
        return '/home';
      }

      // 그 외의 경우는 리디렉션 없음
      return null;
    },
  );
});

// Supabase의 인증 상태 변경 Stream을 GoRouter가 이해할 수 있도록 변환해주는 클래스입니다.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    stream.asBroadcastStream().listen((_) => notifyListeners());
  }
}