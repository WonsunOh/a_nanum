import 'package:go_router/go_router.dart';

import '../features/shop_management.dart/categories/view/category_management_screen.dart';
import '../features/dashboard/view/dashboard_screen.dart';
import '../features/group_buy_management/view/group_buy_management_screen.dart';
import '../features/cs_management.dart/inquiries/view/inquiry_management_screen.dart';
import '../features/order_management/view/order_management_screen.dart';
import '../features/shop_management.dart/products/view/product_management_screen.dart';
import '../features/cs_management.dart/templates/view/reply_template_screen.dart';
import '../features/user_management/view/user_detail_screen.dart';
import '../features/user_management/view/user_management_screen.dart';

final router = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/products',
      builder: (context, state) => const ProductManagementScreen(),
    ),
    
    // 💡 카테고리 경로 추가
    GoRoute(
      path: '/categories',
      builder: (context, state) => const CategoryManagementScreen(),
    ),
    GoRoute(
      path: '/group-buys',
      builder: (context, state) => const GroupBuyManagementScreen(),
    ),
    GoRoute(
      path: '/orders',
      builder: (context, state) => const OrderManagementScreen(),
    ),
    GoRoute(
      path: '/users',
      builder: (context, state) => const UserManagementScreen(),
    ),
    GoRoute(
      path: '/inquiries',
      builder: (context, state) => const InquiryManagementScreen(),
      // 💡 /inquiries의 자식 경로로 /templates를 추가합니다.
      routes: [
        GoRoute(
          path: 'templates', // 예: /inquiries/templates
          builder: (context, state) => const ReplyTemplateScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/users',
      builder: (context, state) => const UserManagementScreen(),
      // 💡 /users/:id 형태의 자식 경로 추가
      routes: [
        GoRoute(
          path: ':id', // 예: /users/user-uuid
          builder: (context, state) {
            final userId = state.pathParameters['id']!;
            return UserDetailScreen(userId: userId);
          },
        ),
      ],
    ),
  ],
);