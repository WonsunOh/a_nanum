// user_app/lib/core/widgets/main_layout.dart (수정)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/category_model.dart';
import '../../features/shop/viewmodel/category_viewmodel.dart';
import '../../features/shop/widgets/category_sidebar.dart';
import '../../features/shop/providers/category_filter_provider.dart';

class MainLayout extends ConsumerStatefulWidget {
  final Widget child;
  final bool showCategorySidebar;

  const MainLayout({
    super.key,
    required this.child,
    this.showCategorySidebar = true,
  });

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 1200;
        final bool isTablet =
            constraints.maxWidth >= 768 && constraints.maxWidth < 1200;
        final bool isMobile = constraints.maxWidth < 768;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.grey.shade100,
          drawer: (isMobile || isTablet) && widget.showCategorySidebar
              ? _buildDrawer(categoriesAsync)
              : null,
          body: Column(
            children: [
              // 커스텀 헤더
              _buildCustomHeader(isMobile, isTablet),
              // 메인 콘텐츠
              Expanded(
                child: isDesktop && widget.showCategorySidebar
                    ? _buildDesktopLayout(categoriesAsync)
                    : _buildMobileLayout(),
              ),
            ],
          ),
        );
      },
    );
  }

  // 데스크톱 레이아웃 (사이드바 + 메인 콘텐츠)
  Widget _buildDesktopLayout(AsyncValue<List<CategoryModel>> categoriesAsync) {
    final selectedCategoryId = ref.watch(selectedCategoryProvider);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1400), // 최대 너비 제한
        child: Row(
          children: [
            // 좌측 카테고리 사이드바 (고정)
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
                  selectedCategoryId: selectedCategoryId,
                  onCategorySelected: (categoryId) {
                    ref.read(selectedCategoryProvider.notifier).state =
                        categoryId;
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => const Center(child: Text('카테고리 로드 실패')),
              ),
            ),

            // 우측 메인 콘텐츠 영역
            Expanded(
              child: Container(
                color: Colors.grey.shade50,
                child: Column(
                  children: [
                    // 선택된 카테고리 표시
                    if (selectedCategoryId != null) _buildSelectedCategoryBar(),
                    // 메인 콘텐츠
                    Expanded(child: widget.child),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomHeader(bool isMobile, bool isTablet) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // 메뉴/로고
                if ((isMobile || isTablet) && widget.showCategorySidebar)
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.black87),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  )
                else
                  const SizedBox(width: 8),

                GestureDetector(
                  onTap: () => context.go('/shop'),
                  child: Row(
                    children: [
                      const Icon(Icons.store, color: Colors.blue),
                      const SizedBox(width: 12),
                      const Text(
                        '나눔샵',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 40),

                // 검색바
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
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                      ),
                      onChanged: (value) {
                        ref.read(searchQueryProvider.notifier).state = value;
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 24),

                // 액션 버튼들
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => context.go('/shop/cart'),
                      icon: const Icon(
                        Icons.shopping_cart_outlined,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.go('/group-buy'),
                      icon: const Icon(
                        Icons.group_work_outlined,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.go('/shop/mypage'),
                      icon: const Icon(
                        Icons.person_outline,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 모바일/태블릿 레이아웃
  Widget _buildMobileLayout() {
    final selectedCategoryId = ref.watch(selectedCategoryProvider);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1400),
        child: Column(
          children: [
            if (selectedCategoryId != null) _buildSelectedCategoryBar(),
            Expanded(child: widget.child),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(AsyncValue<List<CategoryModel>> categoriesAsync) {
    final selectedCategoryId = ref.watch(selectedCategoryProvider);

    return Drawer(
      child: categoriesAsync.when(
        data: (categories) => CategorySidebar(
          categories: categories,
          selectedCategoryId: selectedCategoryId,
          onCategorySelected: (categoryId) {
            ref.read(selectedCategoryProvider.notifier).state = categoryId;
            Navigator.of(context).pop(); // 드로어 닫기
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => const Center(child: Text('카테고리 로드 실패')),
      ),
    );
  }

  Widget _buildSelectedCategoryBar() {
    final selectedCategoryId = ref.watch(selectedCategoryProvider);
    final categoriesAsync = ref.read(categoriesProvider);

    final categoryName =
        categoriesAsync.when(
          data: (categories) =>
              _findCategoryName(categories, selectedCategoryId!),
          loading: () => '로딩중...',
          error: (_, __) => '카테고리',
        ) ??
        '카테고리';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2)),
      ),
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
                Icon(Icons.category, size: 16, color: Colors.blue.shade700),
                const SizedBox(width: 6),
                Text(
                  categoryName,
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () =>
                      ref.read(selectedCategoryProvider.notifier).state = null,
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

  String? _findCategoryName(List<CategoryModel> categories, int categoryId) {
    for (final category in categories) {
      if (category.id == categoryId) return category.name;
      final childName = _findCategoryName(category.children, categoryId);
      if (childName != null) return childName;
    }
    return null;
  }
}
