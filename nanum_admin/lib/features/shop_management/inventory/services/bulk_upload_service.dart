import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import '../../../../data/models/bulk_upload_model.dart';
import '../../../../data/repositories/inventory_repository.dart';

class BulkUploadService {
  final InventoryRepository _repository;

  BulkUploadService(this._repository);

  // 📌 Excel 파일 파싱
  Future<List<BulkUploadRow>> parseExcelFile(String filePath) async {
    try {
      final bytes = await File(filePath).readAsBytes();
      final excel = Excel.decodeBytes(bytes);
      
      final List<BulkUploadRow> rows = [];
      
      for (var table in excel.tables.keys) {
        final sheet = excel.tables[table];
        if (sheet == null) continue;

        // 첫 번째 행은 헤더로 간주하고 스킵
        for (var rowIndex = 1; rowIndex < sheet.maxRows; rowIndex++) {
          final row = sheet.rows[rowIndex];
          
          // 빈 행 스킵
          if (row.isEmpty || row.every((cell) => cell?.value == null)) {
            continue;
          }

          rows.add(BulkUploadRow(
            rowNumber: rowIndex + 1,
            productCode: _getCellValue(row, 0),
            productName: _getCellValue(row, 1),
            type: _getCellValue(row, 2),
            quantity: _parseCellToInt(row, 3),
            reason: _getCellValue(row, 4),
          ));
        }
      }

      return rows;
    } catch (e) {
      debugPrint('❌ Error parsing Excel file: $e');
      rethrow;
    }
  }

  // 📌 CSV 파일 파싱
  Future<List<BulkUploadRow>> parseCsvFile(String filePath) async {
    try {
      final input = File(filePath).openRead();
      final fields = await input
          .transform(utf8.decoder)
          .transform(const CsvToListConverter())
          .toList();

      final List<BulkUploadRow> rows = [];

      // 첫 번째 행은 헤더로 간주하고 스킵
      for (var i = 1; i < fields.length; i++) {
        final row = fields[i];
        
        // 빈 행 스킵
        if (row.isEmpty || row.every((cell) => cell == null || cell.toString().trim().isEmpty)) {
          continue;
        }

        rows.add(BulkUploadRow(
          rowNumber: i + 1,
          productCode: row.length > 0 ? row[0]?.toString().trim() : null,
          productName: row.length > 1 ? row[1]?.toString().trim() : null,
          type: row.length > 2 ? row[2]?.toString().trim() : null,
          quantity: row.length > 3 ? _parseToInt(row[3]) : null,
          reason: row.length > 4 ? row[4]?.toString().trim() : null,
        ));
      }

      return rows;
    } catch (e) {
      debugPrint('❌ Error parsing CSV file: $e');
      rethrow;
    }
  }

  // 📌 데이터 유효성 검증
  Future<List<BulkUploadRow>> validateRows(List<BulkUploadRow> rows) async {
    final validatedRows = <BulkUploadRow>[];

    for (final row in rows) {
      String? error;
      int? productId;
      bool isValid = true;

      // 1. 필수 필드 체크
      if (row.productCode == null || row.productCode!.isEmpty) {
        error = '상품코드가 없습니다';
        isValid = false;
      } else if (row.type == null || !['in', 'out', 'adjust'].contains(row.type)) {
        error = '타입은 in, out, adjust 중 하나여야 합니다';
        isValid = false;
      } else if (row.quantity == null || row.quantity! <= 0) {
        error = '수량은 0보다 커야 합니다';
        isValid = false;
      } else {
        // 2. 상품 존재 여부 확인
        final product = await _repository.findProductByCode(row.productCode!);
        
        if (product == null) {
          error = '상품코드를 찾을 수 없습니다: ${row.productCode}';
          isValid = false;
        } else {
          productId = product['id'];
          
          // 3. 출고 시 재고 부족 체크
          if (row.type == 'out') {
            final currentStock = product['stock_quantity'] as int;
            if (currentStock < row.quantity!) {
              error = '재고 부족 (현재: $currentStock개, 출고 요청: ${row.quantity}개)';
              isValid = false;
            }
          }
        }
      }

      validatedRows.add(row.copyWith(
        isValid: isValid,
        errorMessage: error,
        productId: productId,
      ));
    }

    return validatedRows;
  }

  // 헬퍼 메서드들
  String? _getCellValue(List<Data?> row, int index) {
    if (index >= row.length) return null;
    final cell = row[index];
    if (cell?.value == null) return null;
    return cell!.value.toString().trim();
  }

  int? _parseCellToInt(List<Data?> row, int index) {
    final value = _getCellValue(row, index);
    if (value == null) return null;
    return int.tryParse(value);
  }

  int? _parseToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }

  // 📌 템플릿 파일 생성
  static String generateTemplateContent() {
    return '''상품코드,상품명,타입,수량,사유
PROD001,테스트 상품,in,100,초기 입고
PROD002,샘플 상품,out,50,판매
PROD003,예시 상품,adjust,200,재고 조정

* 타입: in(입고), out(출고), adjust(재고조정)
* 상품명은 참고용이며, 실제로는 상품코드로 매칭됩니다''';
  }
}