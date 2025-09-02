// lib/core/utils/formatter.dart
import 'package:intl/intl.dart';

class Formatters {
  static final _numberFormat = NumberFormat('#,###');
  static final _currencyFormat = NumberFormat('#,###원');
  static final _dateFormat = DateFormat('yyyy.MM.dd');
  static final _dateTimeFormat = DateFormat('yyyy.MM.dd HH:mm');

  /// 숫자 포맷팅 (3자리마다 콤마)
  static String number(int number) {
    return _numberFormat.format(number);
  }

  /// 가격 포맷팅 (원 단위)
  static String currency(int price) {
    return _currencyFormat.format(price);
  }

  /// 날짜 포맷팅
  static String date(DateTime date) {
    return _dateFormat.format(date);
  }

  /// 날짜시간 포맷팅
  static String dateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  /// 상대적 시간 표시 (n분 전, n시간 전 등)
  static String relativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  /// 파일 크기 포맷팅
  static String fileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// 전화번호 포맷팅
  static String phoneNumber(String phone) {
    // 숫자만 추출
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    
    if (digits.length == 11) {
      return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
    } else if (digits.length == 10) {
      return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
    }
    
    return phone; // 포맷할 수 없으면 원본 반환
  }
}