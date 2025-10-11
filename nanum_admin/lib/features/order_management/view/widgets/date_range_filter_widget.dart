import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../viewmodel/order_viewmodel.dart';

class DateRangeFilterWidget extends ConsumerStatefulWidget {
  const DateRangeFilterWidget({super.key});

  @override
  ConsumerState<DateRangeFilterWidget> createState() => _DateRangeFilterWidgetState();
}

class _DateRangeFilterWidgetState extends ConsumerState<DateRangeFilterWidget> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(orderViewModelProvider.notifier);
    final selectedPeriod = notifier.selectedPeriod;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                '조회 기간',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              if (selectedPeriod == 'custom' && _startDate != null && _endDate != null)
                TextButton.icon(
                  onPressed: _clearCustomDate,
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('초기화', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          // 빠른 선택 버튼
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPeriodChip('오늘', 'today', selectedPeriod),
              _buildPeriodChip('1주일', '1w', selectedPeriod),
              _buildPeriodChip('1개월', '1m', selectedPeriod),
              _buildPeriodChip('3개월', '3m', selectedPeriod),
              _buildPeriodChip('전체', 'all', selectedPeriod),
            ],
          ),
          
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          
          // 사용자 정의 날짜
          Row(
            children: [
              const Text('기간 직접 설정:', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 16),
              _buildDateButton(
                label: _startDate == null
                    ? '시작일'
                    : DateFormat('yyyy-MM-dd').format(_startDate!),
                onPressed: () => _selectDate(context, true),
              ),
              const SizedBox(width: 8),
              const Text('~', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              _buildDateButton(
                label: _endDate == null
                    ? '종료일'
                    : DateFormat('yyyy-MM-dd').format(_endDate!),
                onPressed: () => _selectDate(context, false),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: (_startDate != null && _endDate != null)
                    ? _applyCustomDateRange
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('적용', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String label, String value, String selectedValue) {
    final isSelected = selectedValue == value;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          final notifier = ref.read(orderViewModelProvider.notifier);
          notifier.setSelectedPeriod(value);
          notifier.fetchOrders(isRefresh: true);
          
          // 사용자 정의 날짜 초기화
          setState(() {
            _startDate = null;
            _endDate = null;
          });
        }
      },
      selectedColor: Colors.blue.shade100,
      checkmarkColor: Colors.blue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildDateButton({required String label, required VoidCallback onPressed}) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.calendar_today, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isStartDate ? _startDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ko', 'KR'),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // 시작일이 종료일보다 늦으면 종료일 초기화
          if (_endDate != null && picked.isAfter(_endDate!)) {
            _endDate = null;
          }
        } else {
          // 종료일이 시작일보다 빠르면 설정 불가
          if (_startDate != null && picked.isBefore(_startDate!)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('종료일은 시작일 이후여야 합니다'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          _endDate = picked;
        }
      });
    }
  }

  void _applyCustomDateRange() {
    if (_startDate == null || _endDate == null) return;

    final notifier = ref.read(orderViewModelProvider.notifier);
    notifier.setCustomDateRange(_startDate, _endDate);
    notifier.fetchOrders(isRefresh: true);
  }

  void _clearCustomDate() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    
    final notifier = ref.read(orderViewModelProvider.notifier);
    notifier.setSelectedPeriod('all');
    notifier.fetchOrders(isRefresh: true);
  }
}