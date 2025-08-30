// nanum_admin/lib/features/shop_management.dart/products/widgets/price_edit_dialog.dart (전체 교체)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/product_model.dart';
import '../viewmodel/discount_product_viewmodel.dart';
import '../viewmodel/product_viewmodel.dart';

enum PriceUpdateSource {
  mainList,
  discountList,
}

class PriceEditDialog extends ConsumerStatefulWidget {
  final ProductModel product;

final PriceUpdateSource source;

  const PriceEditDialog({
    super.key, 
    required this.product,
    required this.source,
  });

  @override
  ConsumerState<PriceEditDialog> createState() => _PriceEditDialogState();
}

class _PriceEditDialogState extends ConsumerState<PriceEditDialog> {
  late final TextEditingController _priceController;
  late final TextEditingController _discountPriceController;
  final _formKey = GlobalKey<FormState>();

  // ⭐️ 1. 할인 기간을 관리할 변수 추가
  DateTime? _discountStartDate;
  DateTime? _discountEndDate;

  @override
  void initState() {
    super.initState();
    _priceController =
        TextEditingController(text: widget.product.price.toString());
    _discountPriceController =
        TextEditingController(text: widget.product.discountPrice?.toString() ?? '');
    
    // ⭐️ 2. 기존 상품의 할인 기간으로 변수 초기화
    _discountStartDate = widget.product.discountStartDate;
    _discountEndDate = widget.product.discountEndDate;
  }

  @override
  void dispose() {
    _priceController.dispose();
    _discountPriceController.dispose();
    super.dispose();
  }

  // ⭐️ 3. 날짜 선택 헬퍼 함수 추가
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isStartDate ? _discountStartDate : _discountEndDate) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _discountStartDate = picked;
        } else {
          _discountEndDate = picked;
        }
      });
    }
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final newPrice = int.parse(_priceController.text);
      final newDiscountPrice = int.tryParse(_discountPriceController.text);

      // ⭐️ [해결책] `source` 값에 따라 올바른 ViewModel을 호출하고 타입을 명확히 합니다.
      if (widget.source == PriceUpdateSource.discountList) {
        ref.read(discountProductViewModelProvider.notifier).updateProductPrice(
              productId: widget.product.id,
              price: newPrice,
              discountPrice: newDiscountPrice,
              discountStartDate: _discountStartDate,
              discountEndDate: _discountEndDate,
            );
      } else {
        ref.read(productViewModelProvider.notifier).updateProductPrice(
              productId: widget.product.id,
              price: newPrice,
              discountPrice: newDiscountPrice,
              discountStartDate: _discountStartDate,
              discountEndDate: _discountEndDate,
            );
      }
      Navigator.of(context).pop(true);
    }
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('[${widget.product.name}] 할인 정보 수정'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: '정상 가격'),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? '필수 항목입니다.' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _discountPriceController,
              decoration: const InputDecoration(labelText: '할인 가격 (비우면 할인 없음)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            // ⭐️ 5. 날짜 선택 UI 추가
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: '할인 시작일',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _discountStartDate != null
                            ? "${_discountStartDate!.toLocal()}".split(' ')[0]
                            : '선택 안 함',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: '할인 종료일',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _discountEndDate != null
                            ? "${_discountEndDate!.toLocal()}".split(' ')[0]
                            : '선택 안 함',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _onSave,
          child: const Text('저장'),
        ),
      ],
    );
  }
}