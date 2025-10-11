// nanum_admin/lib/features/shop_management.dart/promotions/view/promotion_management_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// (사전 작업) promotion_model, promotion_repository, promotion_viewmodel을 만들어야 합니다.

// 임시 데이터 모델
class Promotion {
  final String title;
  Promotion(this.title);
}

// 임시 프로바이더
final promotionViewModelProvider = Provider((ref) => [Promotion('가정의 달 프로모션')]);

class PromotionManagementScreen extends ConsumerWidget {
  const PromotionManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promotions = ref.watch(promotionViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로모션 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: 프로모션 생성 페이지로 이동
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: promotions.length,
        itemBuilder: (context, index) {
          final promo = promotions[index];
          return ListTile(
            title: Text(promo.title),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // TODO: 프로모션 수정 페이지로 이동
              },
            ),
          );
        },
      ),
    );
  }
}