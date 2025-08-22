import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router.dart';
import '../../../data/models/group_buy_model.dart';

class ProductCard extends StatelessWidget {
  final GroupBuy groupBuy;
  const ProductCard({super.key, required this.groupBuy});

  @override
  Widget build(BuildContext context) {
    // 💡 groupBuy.product가 null일 경우를 대비한 방어 코드
    final product = groupBuy.product;
    if (product == null) {
      return const Card(child: SizedBox(height: 300, child: Center(child: Text('상품 정보 없음'))));
    }
    
    // 💡 1인당 가격 계산 로직 수정
    final singlePrice = (product.totalPrice / groupBuy.targetParticipants / 100).ceil() * 100;
    final progress = groupBuy.currentParticipants / groupBuy.targetParticipants;
    final remainingDays = groupBuy.expiresAt.difference(DateTime.now()).inDays;

    return InkWell(
      onTap: () {
        context.goNamed(
          AppRoute.groupBuyDetail.name,
          pathParameters: {'id': groupBuy.id.toString()},
          extra: groupBuy,
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        clipBehavior: Clip.antiAlias, // 이미지의 둥근 모서리를 위해 추가
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상품 이미지
            if (product.imageUrl != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  product.imageUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image_not_supported, size: 48),
                ),
              )
            else
              const AspectRatio(
                aspectRatio: 16 / 9,
                child: Center(child: Icon(Icons.image_not_supported, size: 48)),
              ),
            
            // 상품 정보
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    // 💡 수정된 가격 표시
                    '${NumberFormat.currency(locale: 'ko_KR', symbol: '').format(singlePrice)}원 / 1인',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${groupBuy.currentParticipants}/${groupBuy.targetParticipants}개',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      remainingDays > 0 ? '$remainingDays일 남음' : '모집 마감',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}