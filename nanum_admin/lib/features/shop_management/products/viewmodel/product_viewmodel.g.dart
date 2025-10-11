// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProductViewModel)
const productViewModelProvider = ProductViewModelProvider._();

final class ProductViewModelProvider
    extends $AsyncNotifierProvider<ProductViewModel, List<ProductModel>> {
  const ProductViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productViewModelHash();

  @$internal
  @override
  ProductViewModel create() => ProductViewModel();
}

String _$productViewModelHash() => r'250de3ed78808cf214360b140350f8fa8055626e';

abstract class _$ProductViewModel extends $AsyncNotifier<List<ProductModel>> {
  FutureOr<List<ProductModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<ProductModel>>, List<ProductModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<ProductModel>>, List<ProductModel>>,
              AsyncValue<List<ProductModel>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
