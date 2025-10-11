// nanum_admin/lib/core/router.dart (수정된 버전)

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/product_model.dart';
import '../features/auth/view/login_screen.dart';
import '../features/cs_management.dart/inquiries/view/inquiry_management_screen.dart';
import '../features/cs_management.dart/templates/view/reply_template_screen.dart';
import '../features/dashboard/view/dashboard_screen.dart';
import '../features/settings/view/settings_screen.dart';
import '../features/shop_management/categories/view/category_management_screen.dart';
import '../features/shop_management/inventory/view/inventory_dashboard_screen.dart';
import '../features/shop_management/inventory/view/inventory_management_screen.dart';
import '../features/shop_management/products/view/add_edit_product_screen.dart';
import '../features/shop_management/products/view/discount_product_screen.dart';
import '../features/shop_management/products/view/product_management_screen.dart';
import '../features/group_buy_management/view/group_buy_management_screen.dart';
import '../features/order_management/view/order_management_screen.dart';
import '../features/shop_management/promotions/view/promotion_management_screen.dart';
import '../features/user_management/view/user_management_screen.dart';
import '../features/user_management/view/user_detail_screen.dart';
import 'main_layout.dart';

final router = GoRouter(
  initialLocation: '/dashboard',

  // =================================================================
  // 🔧 로그인 문제 해결을 위한 수정된 리디렉션 로직
  // =================================================================
  
  redirect: (BuildContext context, GoRouterState state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isAuthenticated = session != null;
    final isLoggingIn = state.matchedLocation == '/login';
    
    
    // ✅ 1. 로그인 페이지에 있는 경우
    if (isLoggingIn) {
      if (isAuthenticated) {
        return '/dashboard';
      } else {
        return null; // 로그인 페이지 접근 허용
      }
    }

    // ✅ 2. 다른 페이지에 있는 경우
    if (!isAuthenticated) {
      return '/login';
    }

    // ✅ 3. 인증된 상태에서 보호된 페이지 접근
    return null;
  },
  
  // =================================================================
  
  routes: [
    // 🔑 로그인 페이지
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    
    // 🏠 관리자 메인 레이아웃
    ShellRoute(
      builder: (context, state, child) {
        return MainLayout(child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        
        // 쇼핑몰 관리
        GoRoute(
          path: '/shop/products',
          builder: (context, state) => const ProductManagementScreen(),
          routes: [
            GoRoute(
              path: 'new',
              builder: (context, state) => const AddEditProductScreen(),
            ),
            GoRoute(
              path: 'edit/:productId',
              builder: (context, state) {
                final product = state.extra as ProductModel;
                return AddEditProductScreen(productToEdit: product);
              },
            ),
          ],
        ),
        
        GoRoute(
          path: '/shop/discount_products',
          builder: (context, state) => const DiscountProductScreen(),
        ),
        
        GoRoute(
          path: '/shop/promotions',
          builder: (context, state) => const PromotionManagementScreen(),
        ),
        
        GoRoute(
          path: '/shop/categories',
          builder: (context, state) => const CategoryManagementScreen(),
        ),
        
        // 공동구매 관리
        GoRoute(
          path: '/group-buy',
          builder: (context, state) => const GroupBuyManagementScreen(),
        ),
        
        // 주문 관리
        GoRoute(
          path: '/orders/shop',
          builder: (context, state) =>
              const OrderManagementScreen(),
        ),

       // ✅ 기존 재고 관리 경로
GoRoute(
  path: '/shop/inventory',
  builder: (context, state) => const InventoryManagementScreen(),
  routes: [
    // ✅ 재고 대시보드 서브 경로 추가
    GoRoute(
      path: 'dashboard',
      builder: (context, state) => const InventoryDashboardScreen(),
    ),
  ],
),
        
        // 회원 관리
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
        
        // 고객 지원
        GoRoute(
          path: '/cs/inquiries',
          builder: (context, state) => const InquiryManagementScreen(),
        ),
        GoRoute(
          path: '/cs/templates',
          builder: (context, state) => const ReplyTemplateScreen(),
        ),
        
        // 설정
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
  
  // 🔧 에러 처리 개선
  errorBuilder: (context, state) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('페이지를 찾을 수 없습니다', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('경로: ${state.matchedLocation}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('대시보드로 이동'),
            ),
          ],
        ),
      ),
    );
  },
);