// nanum_admin/lib/features/order_management/view/order_management_screen.dart (전체 수정)

import 'package:file_picker/file_picker.dart';
import 'package:web/web.dart' as web;
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/main_layout.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart'; // ⭐️ OrderType enum을 위해 import
import '../viewmodel/order_viewmodel.dart';

import 'dart:js_interop';
import 'dart:typed_data';

class OrderManagementScreen extends ConsumerWidget {
  // ⭐️ 1. 어떤 종류의 주문을 표시할지 외부에서 받습니다.
  final OrderType orderType;
  const OrderManagementScreen({super.key, required this.orderType});

  // 엑셀 내보내기 함수
  void _exportToExcel(List<Order> orders) {
    final excel = Excel.createExcel();
    final Sheet sheet = excel[excel.getDefaultSheet()!];

    // Header 추가
    sheet.appendRow(
      [
        '주문번호',
        '상품명',
        '수량',
        '구매자',
        '연락처',
        '주소',
        // ⭐️ 쇼핑몰 주문에는 송장번호가 없을 수 있으므로, 공동구매일 때만 추가
        if (orderType == OrderType.groupBuy) '송장번호',
      ].map((e) => TextCellValue(e)).toList(),
    );

    // Data 추가
    for (final order in orders) {
      sheet.appendRow([
        TextCellValue(order.participantId.toString()),
        TextCellValue(order.productName),
        IntCellValue(order.quantity),
        TextCellValue(order.userName ?? ''),
        TextCellValue(order.userPhone ?? ''),
        TextCellValue(order.deliveryAddress),
      ]);
    }

    final bytes = excel.save();
    if (bytes != null) {
      final blob = web.Blob(
        [Uint8List.fromList(bytes).toJS].toJS,
        web.BlobPropertyBag(
            type:
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'),
      );
      final url = web.URL.createObjectURL(blob);
      final anchor = web.HTMLAnchorElement()
        ..href = url
        ..style.display = 'none'
        ..download =
            'orders_${orderType.name}_${DateTime.now().toIso8601String().substring(0, 10)}.xlsx';

      web.document.body?.append(anchor);
      anchor.click();

      web.URL.revokeObjectURL(url);
      anchor.remove();
    }
  }

  // 파일 선택 및 업로드 함수
  void _pickAndUploadExcel(WidgetRef ref) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      // ⭐️ orderType에 맞는 ViewModel을 호출합니다.
      await ref
          .read(orderViewModelProvider(orderType).notifier)
          .uploadAndProcessExcel(result.files.single.bytes!);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ⭐️ 2. orderType에 맞는 ViewModel을 watch합니다.
    final ordersAsync = ref.watch(orderViewModelProvider(orderType));
    // ⭐️ 3. orderType에 따라 동적으로 제목을 설정합니다.
    final title =
        orderType == OrderType.shop ? '쇼핑몰 주문내역' : '공동구매 주문내역';

    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title, // ⭐️ 동적으로 설정된 제목 사용
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                ordersAsync.when(
                  data: (orders) => Row(
                    children: [
                      // ⭐️ 공동구매 주문일 때만 송장 업로드 버튼을 보여줍니다.
                      if (orderType == OrderType.groupBuy) ...[
                        ElevatedButton.icon(
                          icon: const Icon(Icons.upload),
                          label: const Text('송장 일괄 업로드'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange),
                          onPressed: ordersAsync.isLoading
                              ? null
                              : () => _pickAndUploadExcel(ref),
                        ),
                        const SizedBox(width: 16),
                      ],
                      ElevatedButton.icon(
                        icon: const Icon(Icons.download),
                        label: const Text('엑셀로 내보내기'),
                        onPressed:
                            orders.isEmpty ? null : () => _exportToExcel(orders),
                      ),
                    ],
                  ),
                  loading: () => const SizedBox(),
                  error: (e, s) => const SizedBox(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ordersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Text('Error: $e'),
                data: (orders) {
                  if (orders.isEmpty) {
                    return const Center(child: Text('처리할 주문이 없습니다.'));
                  }
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        const DataColumn(label: Text('주문번호')),
                        const DataColumn(label: Text('상품명')),
                        const DataColumn(label: Text('수량')),
                        const DataColumn(label: Text('구매자')),
                        const DataColumn(label: Text('연락처')),
                        const DataColumn(label: Text('배송지')),
                        // ⭐️ 공동구매 주문일 때만 송장번호 컬럼을 보여줍니다.
                        if (orderType == OrderType.groupBuy)
                          const DataColumn(label: Text('송장번호')),
                      ],
                      rows: orders.map((order) {
                        return DataRow(cells: [
                          DataCell(Text(order.participantId.toString())),
                          DataCell(Text(order.productName)),
                          DataCell(Text(order.quantity.toString())),
                          DataCell(Text(order.userName ?? '-')),
                          DataCell(Text(order.userPhone ?? '-')),
                          DataCell(Text(order.deliveryAddress)),
                          if (orderType == OrderType.groupBuy)
                            DataCell(
                              // TODO: 송장번호 입력 기능 구현
                              Text('아직 없음'),
                            ),
                        ]);
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}