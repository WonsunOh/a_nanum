import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../viewmodel/inventory_viewmodel.dart';

class InventoryFilterBar extends ConsumerWidget {
  const InventoryFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(inventoryFilterProvider);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '필터',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (filter.hasActiveFilters)
                  TextButton.icon(
                    onPressed: () {
                      ref.read(inventoryFilterProvider.notifier).state = InventoryFilter();
                    },
                    icon: const Icon(Icons.clear, size: 18),
                    label: const Text('필터 초기화'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                // 타입 필터
                _buildTypeFilter(context, ref, filter),
                
                // 시작일 필터
                _buildDateFilter(
                  context,
                  ref,
                  label: '시작일',
                  date: filter.startDate,
                  onSelect: (date) {
                    ref.read(inventoryFilterProvider.notifier).state = 
                        filter.copyWith(startDate: () => date);
                  },
                  onClear: () {
                    ref.read(inventoryFilterProvider.notifier).state = 
                        filter.copyWith(startDate: () => null);
                  },
                ),
                
                // 종료일 필터
                _buildDateFilter(
                  context,
                  ref,
                  label: '종료일',
                  date: filter.endDate,
                  onSelect: (date) {
                    ref.read(inventoryFilterProvider.notifier).state = 
                        filter.copyWith(endDate: () => date);
                  },
                  onClear: () {
                    ref.read(inventoryFilterProvider.notifier).state = 
                        filter.copyWith(endDate: () => null);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeFilter(BuildContext context, WidgetRef ref, InventoryFilter filter) {
    final types = [
      {'value': null, 'label': '전체', 'color': Colors.grey},
      {'value': 'in', 'label': '입고', 'color': Colors.green},
      {'value': 'out', 'label': '출고', 'color': Colors.red},
      {'value': 'adjust', 'label': '조정', 'color': Colors.blue},
    ];

    return Wrap(
      spacing: 8,
      children: types.map((type) {
        final isSelected = filter.type == type['value'];
        final color = type['color'] as Color;
        
        return FilterChip(
          label: Text(type['label'] as String),
          selected: isSelected,
          onSelected: (selected) {
            ref.read(inventoryFilterProvider.notifier).state = 
                filter.copyWith(type: () => selected ? type['value'] as String? : null);
          },
          selectedColor: color.withOpacity(0.2),
          checkmarkColor: color,
          labelStyle: TextStyle(
            color: isSelected ? color : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateFilter(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required DateTime? date,
    required Function(DateTime) onSelect,
    required VoidCallback onClear,
  }) {
    return InkWell(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        
        if (selectedDate != null) {
          onSelect(selectedDate);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: date != null ? Colors.blue : Colors.grey.shade300,
            width: date != null ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: date != null ? Colors.blue.shade50 : Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: date != null ? Colors.blue : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              date != null 
                  ? '$label: ${DateFormat('yyyy-MM-dd').format(date)}'
                  : label,
              style: TextStyle(
                color: date != null ? Colors.blue : Colors.grey[700],
                fontWeight: date != null ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (date != null) ...[
              const SizedBox(width: 8),
              InkWell(
                onTap: onClear,
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}