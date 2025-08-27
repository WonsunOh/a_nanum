// admin_web/lib/core/router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ⭐️ 새로운 파일 경로에 맞게 import 문을 수정했습니다.
import '../data/models/product_model.dart';
import '../features/auth/view/login_screen.dart';
import '../features/cs_management.dart/inquiries/view/inquiry_management_screen.dart';
import '../features/cs_management.dart/templates/view/reply_template_screen.dart';
import '../features/dashboard/view/dashboard_screen.dart';
import '../features/shop_management.dart/categories/view/category_management_screen.dart';
import '../features/shop_management.dart/products/view/add_edit_product_screen.dart';
import '../features/shop_management.dart/products/view/product_management_screen.dart';
import '../features/group_buy_management/view/group_buy_management_screen.dart';
import '../features/order_management/view/order_management_screen.dart';
import '../features/user_management/view/user_management_screen.dart';
import '../features/user_management/view/user_detail_screen.dart';
import 'main_layout.dart';

final router = GoRouter(
  initialLocation: '/dashboard',

  // =================================================================
  // ⭐️⭐️ 개발자용 스위치 (Development Switch) ⭐️⭐️
  // =================================================================
  // 개발 중에는 이 redirect 부분을 주석 처리하여 매번 로그인하는 번거로움을 피하세요.
  // 실제 배포 전에는 반드시 주석을 해제하여 보안을 활성화해야 합니다!
  
  redirect: (BuildContext context, GoRouterState state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isAuthenticated = session != null;
    final isLoggingIn = state.matchedLocation == '/login';

    if (!isAuthenticated && !isLoggingIn) return '/login';
    if (isAuthenticated && isLoggingIn) return '/dashboard';

    return null;
  },
  
  // =================================================================
  
  routes: [

    // ⭐️ 4. 로그인 페이지 경로를 추가합니다.
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    // MainLayout을 사용하여 모든 화면에 공통 사이드바를 적용합니다.
    ShellRoute(
      builder: (context, state, child) {
        return MainLayout(child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        // ⭐️ 새로운 경로 구조를 적용했습니다.
        GoRoute(
          path: '/shop/products',
          builder: (context, state) => const ProductManagementScreen(),
           routes: [
            // 새 상품 등록 경로
            GoRoute(
              path: 'new', // 최종 경로: /shop/products/new
              builder: (context, state) => const AddEditProductScreen(),
            ),
            // 기존 상품 수정 경로
            GoRoute(
              path: 'edit/:productId', // 최종 경로: /shop/products/edit/123
              builder: (context, state) {
                // ⭐️ extra를 통해 전달받은 ProductModel 객체를 화면에 넘겨줍니다.
                final product = state.extra as ProductModel;
                return AddEditProductScreen(productToEdit: product);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/shop/discount_products',
          builder: (context, state) => const ProductManagementScreen(),
        ),GoRoute(
          path: '/shop/promotions',
          builder: (context, state) => const ProductManagementScreen(),
        ),
        GoRoute(
          path: '/shop/categories',
          builder: (context, state) => const CategoryManagementScreen(),
        ),
        GoRoute(
          path: '/group-buy',
          builder: (context, state) => const GroupBuyManagementScreen(),
        ),
        GoRoute(
          path: '/orders',
          builder: (context, state) => const OrderManagementScreen(),
        ),
        GoRoute(
          path: '/users',
          builder: (context, state) => const UserManagementScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final userId = state.pathParameters['id']!;
                return UserDetailScreen(userId: userId);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/cs/inquiries',
          builder: (context, state) => const InquiryManagementScreen(),
        ),
        GoRoute(
          path: '/cs/templates',
          builder: (context, state) => const ReplyTemplateScreen(),
        ),
      ],
    ),
  ],
);