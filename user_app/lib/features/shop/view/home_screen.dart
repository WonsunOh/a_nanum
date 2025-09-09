// user_app/lib/features/shop/view/home_screen.dart (전체 교체)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/product_model.dart';
import '../viewmodel/category_viewmodel.dart';
import '../viewmodel/product_viewmodel.dart';
import '../widgets/category_sidebar.dart';
import '../widgets/product_grid.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int? _selectedCategoryId;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final productsAsync = ref.watch(productViewModelProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        // 화면 크기별 구분점
        final bool isDesktop = constraints.maxWidth >= 1200;
        final bool isTablet =
            constraints.maxWidth >= 768 && constraints.maxWidth < 1200;
        final bool isMobile = constraints.maxWidth < 768;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.grey.shade50,
          appBar: _buildAppBar(isMobile),

          // 모바일/태블릿: Drawer 사용, 데스크톱: 사이드바 고정
          drawer: (isMobile || isTablet) ? _buildDrawer(categoriesAsync) : null,

          body: isDesktop
              ? _buildDesktopLayout(categoriesAsync, productsAsync)
              : _buildMobileLayout(productsAsync, isTablet),
        );
      },
    );
  }

  // 데스크톱 레이아웃 (기존)
  Widget _buildDesktopLayout(
    AsyncValue<List<CategoryModel>> categoriesAsync,
    AsyncValue<List<ProductModel>> productsAsync,
  ) {
    return Row(
      children: [
        // 좌측 사이드바
        Container(
          width: 280,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(2, 0),
              ),
            ],
          ),
          child: categoriesAsync.when(
            data: (categories) => CategorySidebar(
              categories: categories,
              selectedCategoryId: _selectedCategoryId,
              onCategorySelected: _onCategorySelected,
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('카테고리 로드 실패')),
          ),
        ),

        // 우측 상품 영역
        Expanded(
          child: _buildProductArea(productsAsync, 4), // 데스크톱: 4열
        ),
      ],
    );
  }

  // 모바일/태블릿 레이아웃
  Widget _buildMobileLayout(
    AsyncValue<List<ProductModel>> productsAsync,
    bool isTablet,
  ) {
    return Column(
      children: [
        // 카테고리 필터 표시 (선택된 경우만)
        if (_selectedCategoryId != null) _buildSelectedCategoryChip(),

        // 상품 영역
        Expanded(
          child: _buildProductArea(
            productsAsync,
            isTablet ? 3 : 2, // 태블릿: 3열, 모바일: 2열
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(bool isMobile) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: isMobile
          ? IconButton(
              icon: const Icon(Icons.menu, color: Colors.black87),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            )
          : null,
      title: Row(
        children: [
          if (!isMobile) ...[
            const Icon(Icons.store, color: Colors.blue),
            const SizedBox(width: 12),
          ],
          const Text(
            '나눔샵',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Container(
              height: 40,
              constraints: const BoxConstraints(maxWidth: 400),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '상품 검색',
                  hintStyle: const TextStyle(fontSize: 14),
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
                onSubmitted: (value) => setState(() => _searchQuery = value),
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black87),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.person_outlined, color: Colors.black87),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildDrawer(AsyncValue<List<CategoryModel>> categoriesAsync) {
    return Drawer(
      child: categoriesAsync.when(
        data: (categories) => CategorySidebar(
          categories: categories,
          selectedCategoryId: _selectedCategoryId,
          onCategorySelected: (categoryId) {
            _onCategorySelected(categoryId);
            Navigator.of(context).pop(); // 드로어 닫기
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => const Center(child: Text('카테고리 로드 실패')),
      ),
    );
  }

  Widget _buildSelectedCategoryChip() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getCategoryName(_selectedCategoryId!),
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _onCategorySelected(null),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductArea(
    AsyncValue<List<ProductModel>> productsAsync,
    int crossAxisCount,
  ) {
    return productsAsync.when(
      data: (products) {
        final filteredProducts = _filterProducts(products);
        return ProductGrid(
          products: filteredProducts,
          crossAxisCount: crossAxisCount,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('상품 로드 실패: $e')),
    );
  }

  void _onCategorySelected(int? categoryId) {
    setState(() => _selectedCategoryId = categoryId);

    if (categoryId == null) {
      ref.read(productViewModelProvider.notifier).fetchAllProducts();
    } else {
      final categoryIds = _collectCategoryIds(categoryId);
      if (categoryIds.length == 1) {
        ref
            .read(productViewModelProvider.notifier)
            .fetchProductsByCategory(categoryId);
      } else {
        ref
            .read(productViewModelProvider.notifier)
            .fetchProductsByCategoryHierarchy(categoryIds);
      }
    }
  }

  List<ProductModel> _filterProducts(List<ProductModel> products) {
    var filtered = products;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        return product.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  // 기존 헬퍼 메서드들...
  List<int> _collectCategoryIds(int categoryId) {
    final categoriesAsync = ref.read(categoriesProvider);
    return categoriesAsync.when(
      data: (categories) {
        final List<int> ids = [categoryId];
        _collectChildrenIds(categories, categoryId, ids);
        return ids;
      },
      loading: () => [categoryId],
      error: (_, __) => [categoryId],
    );
  }

  void _collectChildrenIds(
    List<CategoryModel> categories,
    int parentId,
    List<int> result,
  ) {
    for (final category in categories) {
      if (category.id == parentId) {
        for (final child in category.children) {
          result.add(child.id);
          _collectChildrenIds([child], child.id, result);
        }
        return;
      }
      _collectChildrenIds(category.children, parentId, result);
    }
  }

  String _getCategoryName(int categoryId) {
    final categoriesAsync = ref.read(categoriesProvider);
    return categoriesAsync.when(
      data: (categories) => _findCategoryName(categories, categoryId) ?? '카테고리',
      loading: () => '로딩중...',
      error: (_, __) => '카테고리',
    );
  }

  String? _findCategoryName(List<CategoryModel> categories, int categoryId) {
    for (final category in categories) {
      if (category.id == categoryId) return category.name;
      final childName = _findCategoryName(category.children, categoryId);
      if (childName != null) return childName;
    }
    return null;
  }
}
