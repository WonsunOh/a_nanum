import 'package:file_picker/file_picker.dart';
import 'package:web/web.dart' as web;
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/main_layout.dart';
import '../../../data/models/order_model.dart';
import '../viewmodel/order_viewmodel.dart';

import 'dart:js_interop'; // 💡 JSArray 변환을 위해 import
import 'dart:typed_data'; // 💡 Uint8List를 위해 import

class OrderManagementScreen extends ConsumerWidget {
  const OrderManagementScreen({super.key});

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
      // 💡 1. List<int>를 Uint8List로, 다시 JSUint8Array로 변환
      final blob = web.Blob(
        [Uint8List.fromList(bytes).toJS].toJS,
        web.BlobPropertyBag(type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'),
      );
      // 💡 2. 메소드 이름을 createObjectURL로 변경
      final url = web.URL.createObjectURL(blob);
      final anchor = web.HTMLAnchorElement()
        ..href = url
        ..style.display = 'none'
        ..download = 'orders_${DateTime.now().toIso8601String().substring(0, 10)}.xlsx';
      
      web.document.body?.append(anchor);
      anchor.click();
      
      web.URL.revokeObjectURL(url);
      anchor.remove();
    }
  }

  // 💡 파일 선택 및 업로드 로직을 처리하는 함수
  void _pickAndUploadExcel(WidgetRef ref) async {
    // 1. 파일 선택기 열기
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true, // 웹에서는 이 옵션으로 파일 데이터를 바로 얻을 수 있음
    );

    if (result != null && result.files.single.bytes != null) {
      // 2. 파일 데이터를 ViewModel으로 전달
      await ref.read(orderViewModelProvider.notifier).uploadAndProcessExcel(result.files.single.bytes!);
    } else {
      // 파일 선택이 취소된 경우
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(orderViewModelProvider);

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
                  '주문/배송 관리',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                ordersAsync.when(
                  data: (orders) => Row(
                    children: [
                      // 💡 송장 업로드 버튼 추가
                    ElevatedButton.icon(
                      icon: const Icon(Icons.upload),
                      label: const Text('송장 일괄 업로드'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      onPressed: ordersAsync.isLoading ? null : () => _pickAndUploadExcel(ref),
                    ),
                    const SizedBox(width: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.download),
                        label: const Text('엑셀로 내보내기'),
                        onPressed: orders.isEmpty
                            ? null
                            : () => _exportToExcel(orders),
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
                      // --- 👇 이 부분을 채워넣습니다 ---
                      columns: const [
                        DataColumn(label: Text('주문번호')),
                        DataColumn(label: Text('상품명')),
                        DataColumn(label: Text('수량')),
                        DataColumn(label: Text('구매자')),
                        DataColumn(label: Text('연락처')),
                        DataColumn(label: Text('배송지')),
                        DataColumn(label: Text('송장번호')),
                      ],
                      rows: orders.map((order) {
                        return DataRow(cells: [
                          DataCell(Text(order.participantId.toString())),
                          DataCell(Text(order.productName)),
                          DataCell(Text(order.quantity.toString())),
                          DataCell(Text(order.userName ?? '-')),
                          DataCell(Text(order.userPhone ?? '-')),
                          DataCell(Text(order.deliveryAddress)),
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
