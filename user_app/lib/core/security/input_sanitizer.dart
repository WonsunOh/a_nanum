// lib/core/security/input_sanitizer.dart
class InputSanitizer {
  /// HTML 태그 제거
  static String removeHtmlTags(String input) {
    return input.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  /// 스크립트 태그 제거
  static String removeScriptTags(String input) {
    return input.replaceAll(RegExp(r'<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>', caseSensitive: false), '');
  }

  /// SQL 인젝션 방지를 위한 특수문자 이스케이프
  static String escapeSqlSpecialChars(String input) {
    return input
        .replaceAll("'", "''")
        .replaceAll('"', '""')
        .replaceAll(';', '\\;')
        .replaceAll('--', '\\--');
  }

  /// 파일명 안전하게 만들기
  static String sanitizeFileName(String fileName) {
    // 위험한 문자들을 언더스코어로 대체
    return fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }

  /// 사용자 입력 전체 정제
  static String sanitizeUserInput(String input) {
    return removeScriptTags(removeHtmlTags(input.trim()));
  }
}