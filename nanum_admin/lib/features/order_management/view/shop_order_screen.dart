// nanum_admin/lib/features/order_management/view/shop_order_screen.dart

import 'package:flutter/material.dart';

import '../../../core/main_layout.dart';

class ShopOrderScreen extends StatelessWidget {
  const ShopOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainLayout(
      child: Center(
        child: Text(
          '쇼핑몰 주문내역 페이지 (개발 예정)',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}