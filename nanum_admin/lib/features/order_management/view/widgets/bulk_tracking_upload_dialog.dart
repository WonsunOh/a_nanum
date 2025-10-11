import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import '../../viewmodel/order_viewmodel.dart';

class BulkTrackingUploadDialog extends ConsumerStatefulWidget {
  const BulkTrackingUploadDialog({super.key});

  @override
  ConsumerState<BulkTrackingUploadDialog> createState() => _BulkTrackingUploadDialogState();
}

class _BulkTrackingUploadDialogState extends ConsumerState<BulkTrackingUploadDialog> {
  List<Map<String, dynamic>>? _parsedData;
  bool _isProcessing = false;
  int? _successCount;
  int? _failCount;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 900,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const Divider(height: 32),
            Expanded(
              child: _parsedData == null
                  ? _buildFileSelectionView()
                  : (_successCount != null
                      ? _buildResultView()
                      : _buildPreviewView()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '송장번호 일괄 등록',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Excel 또는 CSV 파일로 여러 주문의 송장번호를 한번에 등록하세요',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildFileSelectionView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.upload_file, size: 80, color: Colors.blue),
          const SizedBox(height: 24),
          const Text(
            '파일을 선택하여 업로드하세요',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '지원 형식: Excel (.xlsx), CSV (.csv)',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.folder_open),
                label: const Text('파일 선택'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: _downloadTemplate,
                icon: const Icon(Icons.download),
                label: const Text('템플릿 다운로드'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          _buildInstructions(),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
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
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                '파일 형식 안내',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('컬럼 순서: 주문번호, 택배사, 송장번호'),
          const SizedBox(height: 4),
          const Text('• 주문번호는 필수입니다'),
          const SizedBox(height: 4),
          const Text('• 송장번호는 필수입니다'),
          const SizedBox(height: 4),
          const Text('• 택배사는 선택사항입니다'),
          const SizedBox(height: 4),
          const Text('• 송장번호 등록 시 자동으로 "배송중" 상태로 변경됩니다'),
        ],
      ),
    );
  }

  Widget _buildPreviewView() {
    if (_parsedData == null || _parsedData!.isEmpty) {
      return const Center(child: Text('데이터가 없습니다'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                '총 ${_parsedData!.length}건의 송장번호가 등록됩니다',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
                columns: const [
                  DataColumn(label: Text('번호')),
                  DataColumn(label: Text('주문번호')),
                  DataColumn(label: Text('택배사')),
                  DataColumn(label: Text('송장번호')),
                ],
                rows: _parsedData!.asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;
                  return DataRow(
                    cells: [
                      DataCell(Text('${index + 1}')),
                      DataCell(Text(data['order_number'] ?? '-')),
                      DataCell(Text(data['courier_company'] ?? '-')),
                      DataCell(Text(data['tracking_number'] ?? '-')),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                setState(() => _parsedData = null);
              },
              child: const Text('다시 선택'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _isProcessing ? null : _processUpload,
              child: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('등록 시작'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _failCount == 0 ? Icons.check_circle : Icons.warning,
            size: 64,
            color: _failCount == 0 ? Colors.green : Colors.orange,
          ),
          const SizedBox(height: 24),
          Text(
            '처리 완료',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _failCount == 0 ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatCard('전체', _parsedData!.length, Colors.blue),
              const SizedBox(width: 24),
              _buildStatCard('성공', _successCount!, Colors.green),
              const SizedBox(width: 24),
              _buildStatCard('실패', _failCount!, Colors.red),
            ],
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(orderViewModelProvider);
              Navigator.pop(context);
            },
            child: const Text('완료'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'csv'],
      );

      if (result == null || result.files.single.path == null) return;

      final filePath = result.files.single.path!;
      final extension = filePath.split('.').last.toLowerCase();

      List<Map<String, dynamic>> data;
      if (extension == 'xlsx') {
        data = await _parseExcelFile(filePath);
      } else {
        data = await _parseCsvFile(filePath);
      }

      setState(() => _parsedData = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('파일 처리 오류: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<List<Map<String, dynamic>>> _parseExcelFile(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    final excel = Excel.decodeBytes(bytes);

    final List<Map<String, dynamic>> data = [];

    for (var table in excel.tables.keys) {
      final sheet = excel.tables[table];
      if (sheet == null) continue;

      for (var rowIndex = 1; rowIndex < sheet.maxRows; rowIndex++) {
        final row = sheet.rows[rowIndex];

        if (row.isEmpty || row.every((cell) => cell?.value == null)) {
          continue;
        }

        data.add({
          'order_number': _getCellValue(row, 0),
          'courier_company': _getCellValue(row, 1),
          'tracking_number': _getCellValue(row, 2),
        });
      }
    }

    return data;
  }

  Future<List<Map<String, dynamic>>> _parseCsvFile(String filePath) async {
    final input = File(filePath).openRead();
    final fields = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter())
        .toList();

    final List<Map<String, dynamic>> data = [];

    for (var i = 1; i < fields.length; i++) {
      final row = fields[i];

      if (row.isEmpty || row.every((cell) => cell == null || cell.toString().trim().isEmpty)) {
        continue;
      }

      data.add({
        'order_number': row.length > 0 ? row[0]?.toString().trim() : null,
        'courier_company': row.length > 1 ? row[1]?.toString().trim() : null,
        'tracking_number': row.length > 2 ? row[2]?.toString().trim() : null,
      });
    }

    return data;
  }

  String? _getCellValue(List<Data?> row, int index) {
    if (index >= row.length) return null;
    final cell = row[index];
    if (cell?.value == null) return null;
    return cell!.value.toString().trim();
  }

  Future<void> _processUpload() async {
    if (_parsedData == null) return;

    setState(() => _isProcessing = true);

    try {
      await ref.read(orderViewModelProvider.notifier).batchUpdateTrackingNumbers(_parsedData!);

      setState(() {
        _successCount = _parsedData!.length;
        _failCount = 0;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _successCount = 0;
        _failCount = _parsedData!.length;
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('처리 실패: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _downloadTemplate() async {
    try {
      var excel = Excel.createExcel();
      Sheet sheet = excel['템플릿'];

      sheet.appendRow([
        TextCellValue('주문번호'),
        TextCellValue('택배사'),
        TextCellValue('송장번호'),
      ]);

      sheet.appendRow([
        TextCellValue('ORD-20250101-001'),
        TextCellValue('CJ대한통운'),
        TextCellValue('123456789012'),
      ]);

      sheet.appendRow([
        TextCellValue('ORD-20250101-002'),
        TextCellValue('우체국택배'),
        TextCellValue('987654321098'),
      ]);

      var fileBytes = excel.save();
      if (fileBytes == null) throw Exception('파일 생성 실패');

      final uint8ListBytes = Uint8List.fromList(fileBytes);

      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: '템플릿 저장',
        fileName: '송장번호_일괄등록_템플릿_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx',
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        bytes: uint8ListBytes,
      );

      if (outputPath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ 템플릿이 저장되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('다운로드 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}