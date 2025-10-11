import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../viewmodel/inventory_viewmodel.dart';

class StockAdjustDialog extends ConsumerStatefulWidget {
  const StockAdjustDialog({super.key});

  @override
  ConsumerState<StockAdjustDialog> createState() => _StockAdjustDialogState();
}

class _StockAdjustDialogState extends ConsumerState<StockAdjustDialog> {
  final _searchController = TextEditingController();
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();
  
  Map<String, dynamic>? _selectedProduct;
  String _adjustType = 'in'; // 'in', 'out', 'adjust'

  @override
  void dispose() {
    _searchController.dispose();
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '재고 조정',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 32),
            
            // 1단계: 상품 검색
            _buildProductSearch(),
            
            if (_selectedProduct != null) ...[
              const SizedBox(height: 24),
              
              // 2단계: 선택된 상품 정보
              _buildSelectedProduct(),
              
              const SizedBox(height: 24),
              
              // 3단계: 조정 타입 선택
              _buildAdjustTypeSelector(),
              
              const SizedBox(height: 16),
              
              // 4단계: 수량 입력
              _buildQuantityInput(),
              
              const SizedBox(height: 16),
              
              // 5단계: 사유 입력
              _buildReasonInput(),
              
              const SizedBox(height: 24),
              
              // 제출 버튼
              _buildSubmitButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductSearch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '상품 검색',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: '상품명을 입력하세요',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _selectedProduct = null;
                      });
                    },
                  )
                : null,
          ),
          onChanged: (value) => setState(() {}),
        ),
        const SizedBox(height: 8),
        
        // 검색 결과
        if (_searchController.text.isNotEmpty && _selectedProduct == null)
          _buildSearchResults(),
      ],
    );
  }

  Widget _buildSearchResults() {
    final searchAsync = ref.watch(productSearchProvider(_searchController.text));
    
    return searchAsync.when(
      data: (products) {
        if (products.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('검색 결과가 없습니다.', style: TextStyle(color: Colors.grey)),
            ),
          );
        }
        
        return Container(
          constraints: const BoxConstraints(maxHeight: 200),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: products.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                title: Text(product['name']),
                subtitle: Text('현재 재고: ${product['stock_quantity']}개'),
                trailing: Text(
                  '₩${NumberFormat('#,###').format(product['total_price'])}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  setState(() {
                    _selectedProduct = product;
                    _searchController.text = product['name'];
                  });
                },
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Container(
        padding: const EdgeInsets.all(16),
        child: Text('오류: $e', style: const TextStyle(color: Colors.red)),
      ),
    );
  }

  Widget _buildSelectedProduct() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedProduct!['name'],
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '현재 재고',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              Text(
                '${_selectedProduct!['stock_quantity']}개',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '조정 유형',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: 'in',
              label: Text('입고'),
              icon: Icon(Icons.add_circle_outline),
            ),
            ButtonSegment(
              value: 'out',
              label: Text('출고'),
              icon: Icon(Icons.remove_circle_outline),
            ),
            ButtonSegment(
              value: 'adjust',
              label: Text('재고조정'),
              icon: Icon(Icons.tune),
            ),
          ],
          selected: {_adjustType},
          onSelectionChanged: (Set<String> newSelection) {
            setState(() {
              _adjustType = newSelection.first;
            });
          },
        ),
      ],
    );
  }

  Widget _buildQuantityInput() {
    return TextField(
      controller: _quantityController,
      decoration: InputDecoration(
        labelText: _adjustType == 'adjust' ? '변경할 재고 수량' : '수량',
        hintText: _adjustType == 'adjust' 
            ? '최종 재고 수량을 입력하세요'
            : '${_adjustType == 'in' ? '입고' : '출고'}할 수량을 입력하세요',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        suffixText: '개',
        prefixIcon: Icon(
          _adjustType == 'in' 
              ? Icons.arrow_downward 
              : _adjustType == 'out' 
                  ? Icons.arrow_upward 
                  : Icons.edit,
          color: _adjustType == 'in'
              ? Colors.green
              : _adjustType == 'out'
                  ? Colors.red
                  : Colors.blue,
        ),
      ),
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildReasonInput() {
    return TextField(
      controller: _reasonController,
      decoration: InputDecoration(
        labelText: '사유 (선택)',
        hintText: '재고 조정 사유를 입력하세요',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      maxLines: 2,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          _adjustType == 'in' ? '입고 처리' : _adjustType == 'out' ? '출고 처리' : '재고 조정',
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  void _handleSubmit() async {
    final quantity = int.tryParse(_quantityController.text);
    
    if (quantity == null || quantity <= 0) {
      _showSnackBar('올바른 수량을 입력해주세요.', Colors.red);
      return;
    }

    try {
      await ref.read(inventoryLogsProvider.notifier).adjustStock(
        productId: _selectedProduct!['id'],
        type: _adjustType,
        quantity: quantity,
        reason: _reasonController.text.isEmpty ? null : _reasonController.text,
      );

      if (mounted) {
        Navigator.pop(context);
        _showSnackBar('재고가 성공적으로 조정되었습니다.', Colors.green);
        ref.invalidate(stockAlertsProvider);
      }
    } catch (e) {
      _showSnackBar('오류: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }
}