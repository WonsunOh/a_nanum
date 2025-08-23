// admin_web/lib/features/shop_management/products/view/product_management_screen.dart (전체 교체)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/category_model.dart';
import '../viewmodel/product_viewmodel.dart';
import '../../categories/viewmodel/category_viewmodel.dart';
import '../widgets/add_edit_product_dialog.dart';

class ProductManagementScreen extends ConsumerStatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  ConsumerState<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends ConsumerState<ProductManagementScreen> {

  final ScrollController _horizontalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productViewModelProvider);
    final categoriesAsync = ref.watch(categoriesProvider); // 카테고리 목록도 가져옵니다.

    return Scaffold(
      appBar: AppBar(
        title: const Text('상품 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: '새 상품 등록',
            // ⭐️ 2. onPressed에 빈 함수라도 연결해야 합니다.
            onPressed: () {
              // 카테고리 목록이 정상적으로 로드되었는지 확인
              if (categoriesAsync is AsyncData<List<CategoryModel>>) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AddEditProductDialog(
                      categories: categoriesAsync.value, // 로드된 카테고리 목록 전달
                    );
                  },
                );
              } else {
                // 카테고리 로딩 중이거나 에러 발생 시
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('카테고리 정보를 불러오는 중입니다...')),
                );
              }
            },
          ),
        ],
      ),
      // ⭐️ 3. AsyncValue.when에는 data, loading, error 세 가지 상태를 모두 처리해야 합니다.
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return const Center(child: Text('등록된 상품이 없습니다.'));
          }
          return Scrollbar(
            controller: _horizontalController, // 컨트롤러 연결
            thumbVisibility: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, // 가로 스크롤 설정
              padding: const EdgeInsets.all(16.0),
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('상품명')),
                  DataColumn(label: Text('가격')),
                  DataColumn(label: Text('재고')),
                  DataColumn(label: Text('진열 상태')),
                  DataColumn(label: Text('관리')),
                ],
                // ⭐️ 4. .map()의 결과는 Iterable이므로 .toList()로 변환해야 합니다.
                rows: products.map((product) {
                  return DataRow(cells: [
                    DataCell(Text(product.id.toString())),
                    DataCell(Text(product.name)),
                    DataCell(Text('${product.price}원')),
                    DataCell(Text('${product.stockQuantity}개')),
                    DataCell(
                      product.isDisplayed
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.cancel, color: Colors.red),
                    ),
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          tooltip: '수정',
                          onPressed: () {
                             // TODO: 상품 수정 다이얼로그
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.redAccent),
                          tooltip: '삭제',
                          onPressed: () {
                            // TODO: 상품 삭제 확인 다이얼로그
                          },
                        ),
                      ],
                    )),
                  ]);
                }).toList(), // ⭐️ .toList() 추가
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          debugPrint('Error: $error');
          debugPrint('StackTrace: $stackTrace');
        }),
    );
  }
}
