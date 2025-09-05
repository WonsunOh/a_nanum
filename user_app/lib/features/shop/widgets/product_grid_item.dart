// user_app/lib/features/shop/widgets/product_grid_item.dart (전체 교체)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/product_model.dart';

class ProductGridItem extends StatelessWidget {
  final ProductModel product;
  const ProductGridItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ⭐️ 이미지 영역에 패딩을 추가하여 여백을 만듭니다
          Padding(
            padding: const EdgeInsets.all(8.0), // 상품 이미지 주변 여백 추가
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8), // 이미지 모서리를 둥글게
              child: AspectRatio(
                aspectRatio: 1.3, // ⭐️ 1.2에서 1.3으로 변경 (이미지가 덜 세로로 길어짐)
                child: (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                    ? Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) =>
                            progress == null
                                ? child
                                : const Center(child: CircularProgressIndicator()),
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                              color: Colors.grey.shade100,
                              child: const Center(
                                child: Icon(Icons.error_outline, 
                                size: 40, 
                                color: Colors.grey,
                              ),
                            ),
                        ),
                      )
                    : Container(
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: Icon(Icons.image_not_supported_outlined, 
                          size: 40, 
                          color: Colors.grey,
                        ),
                      ),
                ),
              ),
            ),
          ),
          // ⭐️ 텍스트 영역도 패딩을 조정합니다
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 12.0), // 좌우 패딩 증가
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600, // ⭐️ 폰트 굵기 추가
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8), // ⭐️ 상품명과 가격 사이 여백
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      currencyFormat.format(product.price),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary, // ⭐️ 가격을 브랜드 컬러로
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}