import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/main_layout.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/models/product_model.dart';
import '../viewmodel/product_viewmodel.dart';

class ProductManagementScreen extends ConsumerWidget {
  const ProductManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productViewModelProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('상품 마스터 관리', style: Theme.of(context).textTheme.headlineSmall),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('새 상품 등록'),
                  onPressed: () => _showProductDialog(context, ref),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: (!productsAsync.hasValue || !categoriesAsync.hasValue)
                  ? const Center(child: CircularProgressIndicator())
                  : LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minWidth: constraints.maxWidth),
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('썸네일')),
                                DataColumn(label: Text('상품명')),
                                DataColumn(label: Text('카테고리')),
                                DataColumn(label: Text('가격')),
                                DataColumn(label: Text('외부 ID')),
                                DataColumn(label: Text('관리')),
                              ],
                              rows: productsAsync.value!.map((product) {
                                final allCategories = categoriesAsync.value!;
                                String categoryPath = '미지정';
                                if (product.categoryId != null) {
                                  try {
                                    final category = allCategories.firstWhere((c) => c.id == product.categoryId);
                                    List<String> path = [category.name];
                                    Category? current = category;
                                    while (current?.parentId != null) {
                                      current = allCategories.firstWhere((p) => p.id == current!.parentId);
                                      path.insert(0, current.name);
                                    }
                                    categoryPath = path.join(' > ');
                                  } catch (e) {
                                    categoryPath = '삭제된 카테고리';
                                  }
                                }
                                                  
                                return DataRow(cells: [
                                  DataCell(
                                    product.imageUrl != null
                                        ? CircleAvatar(backgroundImage: NetworkImage(product.imageUrl!))
                                        : const CircleAvatar(child: Icon(Icons.image_not_supported)),
                                  ),
                                  DataCell(Text(product.name)),
                                  DataCell(Text(categoryPath)),
                                  DataCell(Text('${product.totalPrice}원')),
                                  DataCell(Text(product.externalProductId ?? '-')),
                                  DataCell(Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () => _showProductDialog(context, ref, existingProduct: product),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () async {
                                          final confirm = await _showDeleteConfirmDialog(context);
                                          if (confirm == true) {
                                            await ref.read(productViewModelProvider.notifier).deleteProduct(product.id);
                                          }
                                        },
                                      ),
                                    ],
                                  )),
                                ]);
                              }).toList(),
                            ),
                          ),
                        );
                    }
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// 상품 등록/수정 다이얼로그
  void _showProductDialog(BuildContext context, WidgetRef ref, {Product? existingProduct}) {
    final viewModel = ref.read(productViewModelProvider.notifier);
    final isEditing = existingProduct != null;
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(text: existingProduct?.name ?? '');
    final priceController = TextEditingController(text: existingProduct?.totalPrice.toString() ?? '');
    final descriptionController = TextEditingController(text: existingProduct?.description ?? '');
    final externalIdController = TextEditingController(text: existingProduct?.externalProductId ?? '');

    final selectedImage = StateProvider<XFile?>((_) => null);
    final selectedCategory = StateProvider<Category?>((ref) {
      if (isEditing && existingProduct.categoryId != null) {
        final allCategories = ref.read(categoriesProvider).value ?? [];
        try {
          return allCategories.firstWhere((c) => c.id == existingProduct.categoryId);
        } catch (e) {
          return null;
        }
      }
      return null;
    });

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Consumer(builder: (context, ref, child) {
          final imageFile = ref.watch(selectedImage);
          final category = ref.watch(selectedCategory);
          final categoriesAsyncValue = ref.watch(categoriesProvider);
          final viewModelState = ref.watch(productViewModelProvider);

          return AlertDialog(
            title: Text(isEditing ? '상품 수정' : '새 상품 등록'),
            content: SizedBox(
              width: 400,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () async {
                          final picker = ImagePicker();
                          ref.read(selectedImage.notifier).state = await picker.pickImage(source: ImageSource.gallery);
                        },
                        child: Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                          child: _buildImagePreview(imageFile, existingProduct),
                        ),
                      ),
                      const SizedBox(height: 16),
                      categoriesAsyncValue.when(
                        loading: () => const CircularProgressIndicator(),
                        error: (e, s) => const Text('카테고리를 불러올 수 없습니다.'),
                        data: (allCategories) {
                          final leafCategories = allCategories.where((c) => !allCategories.any((child) => child.parentId == c.id)).toList();
                          
                          String getCategoryPath(Category cat) {
                            List<String> path = [cat.name];
                            Category? current = cat;
                            while (current?.parentId != null) {
                              try {
                                current = allCategories.firstWhere((p) => p.id == current!.parentId);
                                path.insert(0, current.name);
                              } catch(e) { break; }
                            }
                            return path.join(' > ');
                          }

                          return DropdownButtonFormField<Category>(
                            value: category,
                            hint: const Text('카테고리 선택'),
                            isExpanded: true,
                            items: leafCategories.map((c) {
                              return DropdownMenuItem(value: c, child: Text(getCategoryPath(c)));
                            }).toList(),
                            onChanged: (value) => ref.read(selectedCategory.notifier).state = value,
                            validator: (value) => value == null ? '카테고리를 선택해주세요.' : null,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: '상품명'),
                        validator: (value) => (value == null || value.isEmpty) ? '상품명을 입력해주세요.' : null,
                      ),
                      TextFormField(
                        controller: priceController,
                        decoration: const InputDecoration(labelText: '가격'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) return '가격을 입력해주세요.';
                          if (int.tryParse(value) == null) return '숫자만 입력해주세요.';
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(labelText: '설명 (선택)'),
                      ),
                      TextFormField(
                        controller: externalIdController,
                        decoration: const InputDecoration(labelText: '외부 상품 ID (선택)'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('취소')),
              ElevatedButton(
                onPressed: viewModelState.isLoading ? null : () async {
                  if (formKey.currentState!.validate() == false) return;
                  
                  bool success = false;
                  if (isEditing) {
                    success = await viewModel.updateProduct(
                      existingProduct: existingProduct,
                      name: nameController.text,
                      totalPrice: int.parse(priceController.text),
                      description: descriptionController.text,
                      categoryId: category?.id,
                      externalProductId: externalIdController.text,
                      image: imageFile,
                    );
                  } else {
                    if (imageFile == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('이미지를 선택해주세요.')));
                      return;
                    }
                    success = await viewModel.createProduct(
                      name: nameController.text,
                      totalPrice: int.parse(priceController.text),
                      description: descriptionController.text,
                      image: imageFile,
                      categoryId: category!.id,
                      externalProductId: externalIdController.text,
                    );
                  }

                  if (success && dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isEditing ? '상품이 수정되었습니다.' : '상품이 등록되었습니다.')),
                    );
                  }
                },
                child: viewModelState.isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                    : const Text('저장'),
              ),
            ],
          );
        });
      },
    );
  }

  /// 이미지 미리보기 위젯
  Widget _buildImagePreview(XFile? localImage, Product? existingProduct) {
    if (localImage != null) {
      return Image.network(localImage.path, fit: BoxFit.cover);
    }
    if (existingProduct?.imageUrl != null) {
      return Image.network(existingProduct!.imageUrl!, fit: BoxFit.cover);
    }
    return const Center(child: Text('이미지 선택'));
  }

  /// 삭제 확인 다이얼로그
  Future<bool?> _showDeleteConfirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('상품 삭제'),
        content: const Text('정말로 이 상품을 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('아니오')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}