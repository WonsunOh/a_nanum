// 📌 일괄 업로드 데이터 모델
class BulkUploadRow {
  final int rowNumber;
  final String? productCode;
  final String? productName;
  final int? quantity;
  final String? type; // 'in', 'out', 'adjust'
  final String? reason;
  
  // 검증 결과
  bool isValid;
  String? errorMessage;
  int? productId; // 검증 후 매칭된 상품 ID

  BulkUploadRow({
    required this.rowNumber,
    this.productCode,
    this.productName,
    this.quantity,
    this.type,
    this.reason,
    this.isValid = false,
    this.errorMessage,
    this.productId,
  });

  BulkUploadRow copyWith({
    bool? isValid,
    String? errorMessage,
    int? productId,
  }) {
    return BulkUploadRow(
      rowNumber: rowNumber,
      productCode: productCode,
      productName: productName,
      quantity: quantity,
      type: type,
      reason: reason,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
      productId: productId ?? this.productId,
    );
  }
}

// 📌 업로드 결과
class BulkUploadResult {
  final int totalRows;
  final int successCount;
  final int failCount;
  final List<String> errors;
  final Duration processingTime;

  BulkUploadResult({
    required this.totalRows,
    required this.successCount,
    required this.failCount,
    required this.errors,
    required this.processingTime,
  });
}