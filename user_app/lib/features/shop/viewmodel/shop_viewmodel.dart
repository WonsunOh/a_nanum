import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/models/product_model.dart';
import '../../../data/repositories/product_repository.dart';

part 'shop_viewmodel.g.dart';

@riverpod
Future<List<ProductModel>> shopViewModel(Ref ref) {
  final productRepository = ref.watch(productRepositoryProvider);
  return productRepository.fetchProducts();
}