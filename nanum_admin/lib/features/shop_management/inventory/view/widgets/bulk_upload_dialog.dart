import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../../data/models/bulk_upload_model.dart';
import '../../../../../data/repositories/inventory_repository.dart';
import '../../services/bulk_upload_service.dart';
import '../../viewmodel/inventory_viewmodel.dart';

class BulkUploadDialog extends ConsumerStatefulWidget {
  const BulkUploadDialog({super.key});

  @override
  ConsumerState<BulkUploadDialog> createState() => _BulkUploadDialogState();
}

class _BulkUploadDialogState extends ConsumerState<BulkUploadDialog> {
  List<BulkUploadRow>? _parsedRows;
  bool _isProcessing = false;
  BulkUploadResult? _result;
  int _currentStep = 0; // 0: 파일선택, 1: 미리보기, 2: 처리중, 3: 결과

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
              child: _buildBody(),
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '재고 일괄 업로드',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              _getStepDescription(),
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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

  String _getStepDescription() {
    switch (_currentStep) {
      case 0:
        return 'Excel 또는 CSV 파일을 선택해주세요';
      case 1:
        return '데이터를 확인하고 처리를 시작하세요';
      case 2:
        return '재고를 업데이트하고 있습니다...';
      case 3:
        return '처리가 완료되었습니다';
      default:
        return '';
    }
  }

  Widget _buildBody() {
    switch (_currentStep) {
      case 0:
        return _buildFileSelectionStep();
      case 1:
        return _buildPreviewStep();
      case 2:
        return _buildProcessingStep();
      case 3:
        return _buildResultStep();
      default:
        return const SizedBox.shrink();
    }
  }

  // 1단계: 파일 선택
  Widget _buildFileSelectionStep() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.upload_file,
            size: 80,
            color: Colors.blue,
          ),
          const SizedBox(height: 24),
          const Text(
            '파일을 선택하거나 드래그하여 업로드하세요',
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
          const Text('컬럼 순서: 상품코드, 상품명, 타입, 수량, 사유'),
          const SizedBox(height: 4),
          const Text('• 타입: in(입고), out(출고), adjust(재고조정)'),
          const SizedBox(height: 4),
          const Text('• 상품코드는 필수이며, 시스템에 등록된 코드여야 합니다'),
          const SizedBox(height: 4),
          const Text('• 수량은 0보다 큰 정수여야 합니다'),
        ],
      ),
    );
  }

  // 2단계: 미리보기
  Widget _buildPreviewStep() {
    if (_parsedRows == null) return const SizedBox.shrink();

    final validRows = _parsedRows!.where((r) => r.isValid).length;
    final invalidRows = _parsedRows!.length - validRows;

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
              _buildStatChip('전체', _parsedRows!.length, Colors.blue),
              const SizedBox(width: 16),
              _buildStatChip('유효', validRows, Colors.green),
              const SizedBox(width: 16),
              _buildStatChip('오류', invalidRows, Colors.red),
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
                  DataColumn(label: Text('행')),
                  DataColumn(label: Text('상태')),
                  DataColumn(label: Text('상품코드')),
                  DataColumn(label: Text('상품명')),
                  DataColumn(label: Text('타입')),
                  DataColumn(label: Text('수량')),
                  DataColumn(label: Text('사유')),
                  DataColumn(label: Text('오류 메시지')),
                ],
                rows: _parsedRows!.map((row) {
                  return DataRow(
                    color: WidgetStateProperty.all(
                      row.isValid ? null : Colors.red.shade50,
                    ),
                    cells: [
                      DataCell(Text(row.rowNumber.toString())),
                      DataCell(
                        Icon(
                          row.isValid ? Icons.check_circle : Icons.error,
                          color: row.isValid ? Colors.green : Colors.red,
                          size: 20,
                        ),
                      ),
                      DataCell(Text(row.productCode ?? '-')),
                      DataCell(Text(row.productName ?? '-')),
                      DataCell(_buildTypeChip(row.type)),
                      DataCell(Text(row.quantity?.toString() ?? '-')),
                      DataCell(
                        SizedBox(
                          width: 150,
                          child: Text(
                            row.reason ?? '-',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 200,
                          child: Text(
                            row.errorMessage ?? '',
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
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
                setState(() {
                  _currentStep = 0;
                  _parsedRows = null;
                });
              },
              child: const Text('다시 선택'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: validRows > 0 ? _processUpload : null,
              child: Text('처리 시작 ($validRows건)'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String? type) {
    if (type == null) return const Text('-');

    Color color;
    String label;
    
    switch (type) {
      case 'in':
        color = Colors.green;
        label = '입고';
        break;
      case 'out':
        color = Colors.red;
        label = '출고';
        break;
      case 'adjust':
        color = Colors.blue;
        label = '조정';
        break;
      default:
        color = Colors.grey;
        label = type;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // 3단계: 처리 중
  Widget _buildProcessingStep() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 24),
          Text(
            '재고를 업데이트하고 있습니다...',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            '잠시만 기다려주세요',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // 4단계: 결과
  Widget _buildResultStep() {
    if (_result == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _result!.failCount == 0 ? Colors.green.shade50 : Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _result!.failCount == 0 ? Colors.green : Colors.orange,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                _result!.failCount == 0 ? Icons.check_circle : Icons.warning,
                size: 64,
                color: _result!.failCount == 0 ? Colors.green : Colors.orange,
              ),
              const SizedBox(height: 16),
              Text(
                '처리 완료',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _result!.failCount == 0 ? Colors.green.shade700 : Colors.orange.shade700,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildResultStat('전체', _result!.totalRows, Colors.blue),
                  const SizedBox(width: 24),
                  _buildResultStat('성공', _result!.successCount, Colors.green),
                  const SizedBox(width: 24),
                  _buildResultStat('실패', _result!.failCount, Colors.red),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '처리 시간: ${_result!.processingTime.inSeconds}초',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        if (_result!.errors.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text(
            '오류 내역',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: ListView.builder(
                itemCount: _result!.errors.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• ${_result!.errors[index]}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                ref.invalidate(inventoryLogsProvider);
                ref.invalidate(stockAlertsProvider);
                Navigator.pop(context);
              },
              child: const Text('완료'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultStat(String label, int count, Color color) {
    return Column(
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
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // 파일 선택
  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'csv'],
      );

      if (result == null || result.files.single.path == null) return;

      setState(() => _isProcessing = true);

      final filePath = result.files.single.path!;
      final extension = filePath.split('.').last.toLowerCase();

      final service = BulkUploadService(ref.read(inventoryRepositoryProvider));
      
      List<BulkUploadRow> rows;
      if (extension == 'xlsx') {
        rows = await service.parseExcelFile(filePath);
      } else {
        rows = await service.parseCsvFile(filePath);
      }

      // 유효성 검증
      final validatedRows = await service.validateRows(rows);

      setState(() {
        _parsedRows = validatedRows;
        _currentStep = 1;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('파일 처리 오류: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

 // _downloadTemplate 메서드 (Excel 버전)
// 📌 템플릿 다운로드 메서드 (크로스 플랫폼 버전)
Future<void> _downloadTemplate() async {
  try {
    // Excel 파일 생성
    var excel = Excel.createExcel();
    Sheet sheet = excel['템플릿'];

    // 헤더 추가
    sheet.appendRow([
      TextCellValue('상품코드'),
      TextCellValue('상품명'),
      TextCellValue('타입'),
      TextCellValue('수량'),
      TextCellValue('사유'),
    ]);

    // 샘플 데이터 추가
    sheet.appendRow([
      TextCellValue('PROD001'),
      TextCellValue('테스트 상품'),
      TextCellValue('in'),
      IntCellValue(100),
      TextCellValue('초기 입고'),
    ]);

    sheet.appendRow([
      TextCellValue('PROD002'),
      TextCellValue('샘플 상품'),
      TextCellValue('out'),
      IntCellValue(50),
      TextCellValue('판매'),
    ]);

    sheet.appendRow([
      TextCellValue('PROD003'),
      TextCellValue('예시 상품'),
      TextCellValue('adjust'),
      IntCellValue(200),
      TextCellValue('재고 조정'),
    ]);

    // 안내사항 시트
    Sheet infoSheet = excel['사용안내'];
    infoSheet.appendRow([TextCellValue('■ 재고 일괄 업로드 템플릿 사용 안내')]);
    infoSheet.appendRow([]);
    infoSheet.appendRow([TextCellValue('1. 필수 컬럼')]);
    infoSheet.appendRow([TextCellValue('   - 상품코드: 시스템에 등록된 상품 코드')]);
    infoSheet.appendRow([TextCellValue('   - 타입: in(입고), out(출고), adjust(재고조정)')]);
    infoSheet.appendRow([TextCellValue('   - 수량: 0보다 큰 정수')]);
    infoSheet.appendRow([]);
    infoSheet.appendRow([TextCellValue('2. 선택 컬럼')]);
    infoSheet.appendRow([TextCellValue('   - 상품명: 참고용 (상품코드로 매칭)')]);
    infoSheet.appendRow([TextCellValue('   - 사유: 재고 변경 사유')]);
    infoSheet.appendRow([]);
    infoSheet.appendRow([TextCellValue('3. 주의사항')]);
    infoSheet.appendRow([TextCellValue('   - 첫 번째 행은 헤더이므로 수정하지 마세요')]);
    infoSheet.appendRow([TextCellValue('   - 상품코드가 존재하지 않으면 업로드 실패')]);
    infoSheet.appendRow([TextCellValue('   - 출고 시 현재 재고보다 많은 수량은 불가')]);

    // Excel 파일을 바이트로 변환
    var fileBytes = excel.save();
    
    if (fileBytes == null) {
      throw Exception('파일 생성 실패');
    }

    // ✅ List<int>를 Uint8List로 변환
    final uint8ListBytes = Uint8List.fromList(fileBytes);

    // 다운로드 폴더에 저장
    String? outputPath = await FilePicker.platform.saveFile(
      dialogTitle: '템플릿 저장',
      fileName: '재고_일괄_업로드_템플릿_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx',
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      bytes: uint8ListBytes, // ✅ 변환된 바이트 사용
    );

    if (outputPath != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Excel 템플릿이 저장되었습니다'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
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


  // 일괄 처리
  Future<void> _processUpload() async {
    if (_parsedRows == null) return;

    setState(() {
      _currentStep = 2;
      _isProcessing = true;
    });

    try {
      final service = BulkUploadService(ref.read(inventoryRepositoryProvider));
      final validRows = _parsedRows!.where((r) => r.isValid).toList();
      
      final result = await ref
          .read(inventoryRepositoryProvider)
          .bulkAdjustStockFromRows(validRows);

      setState(() {
        _result = result;
        _currentStep = 3;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('처리 오류: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}