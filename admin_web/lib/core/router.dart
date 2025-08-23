// admin_web/lib/core/router.dart

import 'package:go_router/go_router.dart';

// ⭐️ 새로운 파일 경로에 맞게 import 문을 수정했습니다.
import '../features/cs_management.dart/inquiries/view/inquiry_management_screen.dart';
import '../features/cs_management.dart/templates/view/reply_template_screen.dart';
import '../features/dashboard/view/dashboard_screen.dart';
import '../features/shop_management.dart/categories/view/category_management_screen.dart';
import '../features/shop_management.dart/products/view/product_management_screen.dart';
import '../features/group_buy_management/view/group_buy_management_screen.dart';
import '../features/order_management/view/order_management_screen.dart';
import '../features/user_management/view/user_management_screen.dart';
import '../features/user_management/view/user_detail_screen.dart';
import 'main_layout.dart';

final router = GoRouter(
  initialLocation: '/dashboard',
  routes: [
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