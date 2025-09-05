// lib/features/shop_management/products/view/product_management_screen.dart (전체 교체)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/repositories/product_repository.dart';
import '../viewmodel/product_viewmodel.dart';
import '../providers/product_providers.dart' hide productVariantsProvider;

class ProductManagementScreen extends ConsumerStatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  ConsumerState<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends ConsumerState<ProductManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';
  bool _isGridView = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productViewModelProvider);
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(productViewModelProvider.future),
              child: productsAsync.when(
                data: (products) => _buildProductsView(products),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => _buildErrorView(e.toString()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      title: const Text(
        '상품 관리',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          onPressed: () => setState(() => _isGridView = !_isGridView),
          icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
          tooltip: _isGridView ? '목록 보기' : '격자 보기',
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () => context.go('/shop/products/new'),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('상품 추가'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(width: 8),
        _buildMoreMenu(),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildMoreMenu() {
    return PopupMenuButton<String>(
      onSelected: _handleMenuSelection,
      itemBuilder: (context) => [
        const PopupMenuItem<String>(
          value: 'delete_images',
          child: Row(
            children: [
              Icon(Icons.delete_sweep, color: Colors.red),
              SizedBox(width: 8),
              Text('이미지 폴더 비우기', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.more_vert),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '상품명으로 검색...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onSubmitted: (value) => _performSearch(value),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => _performSearch(_searchController.text),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('검색'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: _clearSearch,
                child: const Text('초기화'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('필터: ', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(width: 8),
              _buildFilterChip('all', '전체 상품'),
              const SizedBox(width: 8),
              _buildFilterChip('displayed', '진열중'),
              const SizedBox(width: 8),
              _buildFilterChip('hidden', '숨김'),
              const SizedBox(width: 8),
              _buildFilterChip('sold_out', '품절'),
              const SizedBox(width: 8),
              _buildFilterChip('low_stock', '재고부족'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (selected) {
        setState(() => _selectedFilter = selected ? value : 'all');
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: Colors.blue.shade100,
      checkmarkColor: Colors.blue.shade700,
    );
  }

  Widget _buildProductsView(List<ProductModel> products) {
    final filteredProducts = _filterProducts(products);
    
    if (filteredProducts.isEmpty) {
      return _buildEmptyView();
    }

    return _isGridView 
        ? _buildGridView(filteredProducts) 
        : _buildTableView(filteredProducts);
  }

  Widget _buildGridView(List<ProductModel> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) => _buildProductCard(products[index]),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');
    final hasDiscount = product.discountPrice != null && product.discountPrice! > 0;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                color: Colors.grey.shade100,
              ),
              child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => 
                            const Icon(Icons.image_not_supported, size: 48),
                      ),
                    )
                  : const Icon(Icons.image_not_supported, size: 48),
            ),
          ),
          
          // Product Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.categoryPath ?? '미분류',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  
                  // Price
                  if (hasDiscount) ...[
                    Text(
                      currencyFormat.format(product.price),
                      style: TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      currencyFormat.format(product.discountPrice!),
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ] else
                    Text(
                      currencyFormat.format(product.price),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  
                  const Spacer(),
                  
                  // Stock and Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildGridStockChip(product),
                      Row(
                        children: [
                          _buildStatusChip(product.isSoldOut, product.isDisplayed),
                          const SizedBox(width: 4),
                          PopupMenuButton<String>(
                            onSelected: (value) => _handleProductAction(value, product),
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'edit', child: Text('편집')),
                              const PopupMenuItem(value: 'delete', child: Text('삭제')),
                            ],
                            child: const Icon(Icons.more_vert, size: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridStockChip(ProductModel product) {
    final variantsAsync = ref.watch(productVariantsProvider(product.id));
    
    return variantsAsync.when(
      data: (variants) {
        final totalStock = product.calculateTotalStock(variants.isNotEmpty ? variants : null);
        return _buildStockChip(totalStock);
      },
      loading: () => _buildStockChip(product.stockQuantity),
      error: (_, __) => _buildStockChip(product.stockQuantity),
    );
  }

  Widget _buildTableView(List<ProductModel> products) {
    // ✅ 상품 정렬 추가 (최신순)
  final sortedProducts = List<ProductModel>.from(products)
    ..sort((a, b) => b.id.compareTo(a.id));

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        // scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width - 150,
          ),
          child: DataTable(
            columnSpacing: 5, // ✅ 간격 축소: 32 → 16
            horizontalMargin: 24,
            headingRowHeight: 56,
          
            decoration: BoxDecoration(
              
            ),
            // ignore: deprecated_member_use
            dataRowHeight: 72,
            headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
            headingTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            columns: [
              DataColumn(
              label: Container(
                width: 40,
                alignment: Alignment.center,
                child: const Text('이미지'),
              ),
            ),
            DataColumn(
              label: Container(
                width: 120,
                alignment: Alignment.center,
                child: const Text('상품코드'),
              ),
            ),
            DataColumn(
              label: Container(
                width: 300,
                alignment: Alignment.center,
                child: const Text('상품명'),
              ),
            ),
            DataColumn(
              label: Container(
                width: 200,
                alignment: Alignment.center,
                child: const Text('카테고리'),
              ),
            ),
            DataColumn(
              label: Container(
                width: 120,
                alignment: Alignment.center,
                child: const Text('가격'),
              ),
            ),
            DataColumn(
              label: Container(
                width: 120,
                alignment: Alignment.center,
                child: const Text('재고'),
              ),
              numeric: true,
            ),
            DataColumn(
              label: Container(
                width: 120,
                alignment: Alignment.center,
                child: const Text('진열/품절'),
              ),
            ),
            DataColumn(
              label: Container(
                width: 120,
                alignment: Alignment.center,
                child: const Text('관리'),
              ),
            ),
          
            ],
            rows: products.map((product) => _buildDataRow(product)).toList(),
          ),
        ),
      ),
    );
  }

  DataRow _buildDataRow(ProductModel product) {
    final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');
    final hasDiscount = product.discountPrice != null && product.discountPrice! > 0;

    return DataRow(
      cells: [
        // Image
        DataCell(
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Colors.grey.shade100,
            ),
            child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => 
                          const Icon(Icons.image_not_supported, size: 20),
                    ),
                  )
                : const Icon(Icons.image_not_supported, size: 20),
          ),
        ),
        
        // Product Code
        DataCell(
          Container(
            alignment: Alignment.center,
            width: 120, // 80 → 90
            child: Text(
              product.productCode ?? '-',
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        
        // Name
        DataCell(
          SizedBox(
            width: 300,
            child: Text(
              product.name,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        
        // Category
        DataCell(
          Container(
            alignment: Alignment.center,
            width: 200,
            child: Text(
              product.categoryPath ?? '미분류',
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        
        // Price
        DataCell(
          Container(
            alignment: Alignment.center,
            width: 120,
            child: hasDiscount
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        currencyFormat.format(product.price),
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        currencyFormat.format(product.discountPrice!),
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  )
                : Text(
                    currencyFormat.format(product.price),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
          ),
        ),
        
        // Stock
        DataCell(
        Container(
            alignment: Alignment.center,
          width: 120, // 폭 설정
          child: _buildStockCellWithProduct(product),
        ),
      ),       
        
        // Status
        DataCell(
        SizedBox(
          width: 120, // 폭 설정
          child: _buildStatusCellWithRow(product),
        ),
      ),
        
        // Actions
        DataCell(
        SizedBox(
          width: 120, // 폭 설정
          child: _buildActionButtons(product),
        ),
      ),
      ],
    );
  }

  // ✅ 진열/품절을 Row로 변경한 새로운 메서드
Widget _buildStatusCellWithRow(ProductModel product) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      // 진열 상태
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '진열',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          Transform.scale(
            scale: 0.7,
            child: Switch(
              value: product.isDisplayed,
              onChanged: (value) => _toggleProductDisplay(product, value),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              activeColor: Colors.green,
            ),
          ),
        ],
      ),
      // 품절 상태
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '품절',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          Transform.scale(
            scale: 0.7,
            child: Switch(
              value: product.isSoldOut,
              onChanged: (value) => _toggleProductSoldOut(product, value),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              activeColor: Colors.red,
            ),
          ),
        ],
      ),
    ],
  );
}

  Widget _buildStockCellWithProduct(ProductModel product) {
    final variantsAsync = ref.watch(productVariantsProvider(product.id));
    
    return variantsAsync.when(
      data: (variants) {
        final totalStock = product.calculateTotalStock(variants.isNotEmpty ? variants : null);
        
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              totalStock.toString(),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (variants.isNotEmpty)
                  Tooltip(
                    message: '옵션별 재고 합계 (${variants.length}개 옵션)',
                    child: Icon(
                      Icons.auto_awesome,
                      size: 12,
                      color: Colors.blue.shade600,
                    ),
                  ),
                const SizedBox(width: 4),
                _buildStockChip(totalStock),
              ],
            ),
          ],
        );
      },
      loading: () => const SizedBox(
        width: 50,
        height: 40,
        child: Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, __) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            product.stockQuantity.toString(),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          _buildStockChip(product.stockQuantity),
        ],
      ),
    );
  }

  Widget _buildStockChip(int stock) {
    Color color;
    String label;
    
    if (stock <= 0) {
      color = Colors.red;
      label = '없음';
    } else if (stock <= 10) {
      color = Colors.orange;
      label = '부족';
    } else {
      color = Colors.green;
      label = '충분';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButtons(ProductModel product) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 편집 버튼
        Container(
          
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: IconButton(
            icon: const Icon(Icons.edit_outlined, size: 16),
            tooltip: '편집',
            color: Colors.blue.shade700,
            onPressed: () => context.go('/shop/products/edit/${product.id}', extra: product),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ),
        const SizedBox(width: 15),
        // 삭제 버튼
        Container(
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: IconButton(
            icon: const Icon(Icons.delete_outline, size: 16),
            tooltip: '삭제',
            color: Colors.red.shade700,
            onPressed: () => _showDeleteConfirmDialog(product),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(bool isSoldOut, bool isDisplayed) {
    if (isSoldOut) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: const Text(
          '품절',
          style: TextStyle(color: Colors.red, fontSize: 10),
        ),
      );
    }
    
    if (!isDisplayed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: const Text(
          '숨김',
          style: TextStyle(color: Colors.orange, fontSize: 10),
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: const Text(
        '진열중',
        style: TextStyle(color: Colors.green, fontSize: 10),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            '등록된 상품이 없습니다',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            '첫 번째 상품을 등록해보세요',
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/shop/products/new'),
            icon: const Icon(Icons.add),
            label: const Text('상품 추가'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text('오류: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.refresh(productViewModelProvider.future),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  // Event Handlers
  void _performSearch(String query) {
    ref.read(productViewModelProvider.notifier).searchProducts(query);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _selectedFilter = 'all');
    ref.read(productViewModelProvider.notifier).fetchAllProducts();
  }

  List<ProductModel> _filterProducts(List<ProductModel> products) {
    List<ProductModel> filtered;

    switch (_selectedFilter) {
    case 'displayed':
      filtered = products.where((p) => p.isDisplayed).toList();
      break;
    case 'hidden':
      filtered = products.where((p) => !p.isDisplayed).toList();
      break;
    case 'sold_out':
      filtered = products.where((p) => p.isSoldOut).toList();
      break;
    case 'low_stock':
      filtered = products.where((p) => p.stockQuantity <= 10 && p.stockQuantity > 0).toList();
      break;
    default:
      filtered = products;
  }
  
  // ✅ 필터된 결과도 정렬
  filtered.sort((a, b) => b.id.compareTo(a.id));
  return filtered;
}

  void _toggleProductDisplay(ProductModel product, bool value) {
    final updatedProduct = product.copyWith(isDisplayed: value);
    ref.read(productViewModelProvider.notifier).updateProductDetails(updatedProduct);
    
    // Variants 새로고침
    ref.invalidate(productVariantsProvider(product.id));
  }

  void _toggleProductSoldOut(ProductModel product, bool value) {
    final updatedProduct = product.copyWith(isSoldOut: value);
    ref.read(productViewModelProvider.notifier).updateProductDetails(updatedProduct);
    
    // Variants 새로고침
    ref.invalidate(productVariantsProvider(product.id));
  }

  void _handleProductAction(String action, ProductModel product) {
    switch (action) {
      case 'edit':
        context.go('/shop/products/edit/${product.id}', extra: product);
        break;
      case 'delete':
        _showDeleteConfirmDialog(product);
        break;
    }
  }

  void _handleMenuSelection(String value) async {
    if (value == 'delete_images') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('삭제 확인'),
          content: const Text(
            'products/public 폴더의 모든 이미지가 영구적으로 삭제됩니다. 이 작업은 되돌릴 수 없습니다.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('삭제', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirm == true && mounted) {
        _showLoadingDialog();
        await ref.read(productRepositoryProvider).emptyPublicFolderInProducts();
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('이미지 삭제 작업을 요청했습니다.')),
          );
        }
      }
    }
  }

  void _showDeleteConfirmDialog(ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('상품 삭제'),
        content: Text('"${product.name}" 상품을 정말로 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(productViewModelProvider.notifier).deleteProduct(product.id);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }
}