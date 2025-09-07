// user_app/lib/core/utils/phone_input_formatter.dart

import 'package:flutter/services.dart';

/// 한국 전화번호 형식(010-1234-5678)으로 자동 포맷팅하는 TextInputFormatter
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 숫자만 추출
    final String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    // 11자리를 넘으면 자르기
    final String trimmedDigits = digitsOnly.length > 11 
        ? digitsOnly.substring(0, 11) 
        : digitsOnly;
    
    // 포맷팅된 문자열 생성
    String formatted = _formatPhoneNumber(trimmedDigits);
    
    // 커서 위치 계산
    int cursorPosition = _calculateCursorPosition(
      oldValue.text, 
      newValue.text, 
      formatted, 
      newValue.selection.baseOffset
    );
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
  
  /// 전화번호 포맷팅 로직
  String _formatPhoneNumber(String digits) {
    if (digits.isEmpty) return '';
    
    // 010으로 시작하는 휴대폰 번호 형식
    if (digits.startsWith('010')) {
      if (digits.length <= 3) {
        return digits;
      } else if (digits.length <= 7) {
        return '${digits.substring(0, 3)}-${digits.substring(3)}';
      } else {
        return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
      }
    }
    // 일반 전화번호 (지역번호 포함)
    else if (digits.startsWith('02')) {
      // 서울 (02-XXXX-XXXX)
      if (digits.length <= 2) {
        return digits;
      } else if (digits.length <= 6) {
        return '${digits.substring(0, 2)}-${digits.substring(2)}';
      } else {
        return '${digits.substring(0, 2)}-${digits.substring(2, 6)}-${digits.substring(6)}';
      }
    }
    else if (digits.length >= 3 && ['031', '032', '033', '041', '042', '043', '044', '051', '052', '053', '054', '055', '061', '062', '063', '064'].contains(digits.substring(0, 3))) {
      // 3자리 지역번호 (031-XXX-XXXX)
      if (digits.length <= 3) {
        return digits;
      } else if (digits.length <= 6) {
        return '${digits.substring(0, 3)}-${digits.substring(3)}';
      } else {
        return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
      }
    }
    // 기타 번호는 010 형식으로 처리
    else {
      if (digits.length <= 3) {
        return digits;
      } else if (digits.length <= 7) {
        return '${digits.substring(0, 3)}-${digits.substring(3)}';
      } else {
        return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
      }
    }
  }
  
  /// 커서 위치 계산
  int _calculateCursorPosition(String oldText, String newText, String formattedText, int cursorOffset) {
    // 입력된 문자 수를 기준으로 커서 위치 조정
    final int oldDigitCount = oldText.replaceAll(RegExp(r'[^\d]'), '').length;
    final int newDigitCount = newText.replaceAll(RegExp(r'[^\d]'), '').length;
    final int digitDifference = newDigitCount - oldDigitCount;
    
    if (digitDifference == 0) {
      // 문자가 추가/삭제되지 않은 경우 (하이픈 입력 등)
      return formattedText.length;
    }
    
    // 숫자가 추가/삭제된 경우 적절한 위치로 커서 이동
    final String digitsBeforeCursor = newText.substring(0, cursorOffset).replaceAll(RegExp(r'[^\d]'), '');
    int targetPosition = 0;
    int digitCount = 0;
    
    for (int i = 0; i < formattedText.length; i++) {
      if (RegExp(r'\d').hasMatch(formattedText[i])) {
        digitCount++;
        if (digitCount >= digitsBeforeCursor.length) {
          targetPosition = i + 1;
          break;
        }
      }
    }
    
    return targetPosition.clamp(0, formattedText.length);
  }
}

/// 사용 편의성을 위한 헬퍼 함수들
class PhoneNumberUtils {
  /// 포맷팅된 전화번호에서 숫자만 추출 (안전한 버전)
  static String extractDigits(String? formattedPhone) {
    if (formattedPhone == null || formattedPhone.isEmpty) return '';
    try {
      return formattedPhone.replaceAll(RegExp(r'[^\d]'), '');
    } catch (e) {
      return '';
    }
  }
  
  /// 전화번호 유효성 검사 (안전한 버전)
  static bool isValidPhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) return false;
    
    try {
      final String digits = extractDigits(phone);
      
      // 휴대폰 번호 (010-XXXX-XXXX)
      if (digits.startsWith('010') && digits.length == 11) {
        return true;
      }
      
      // 서울 지역번호 (02-XXXX-XXXX)
      if (digits.startsWith('02') && digits.length >= 9 && digits.length <= 10) {
        return true;
      }
      
      // 기타 지역번호 (0XX-XXX-XXXX)
      if (digits.length >= 10 && digits.length <= 11 && digits.startsWith('0')) {
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }
  
  /// 전화번호 포맷팅 (안전한 버전)
  static String formatPhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) return '';
    
    try {
      // 먼저 숫자만 추출
      final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
      if (digits.isEmpty) return '';
      
      // 직접 포맷팅 (PhoneInputFormatter 사용하지 않고)
      return _directFormat(digits);
    } catch (e) {
      print('PhoneNumberUtils.formatPhoneNumber 에러: $e');
      return phone; // 에러 시 원본 반환
    }
  }
  
  /// 직접 포맷팅 (더 안전한 방법)
  static String _directFormat(String digits) {
    if (digits.isEmpty) return '';
    
    // 11자리 초과 시 자르기
    if (digits.length > 11) {
      digits = digits.substring(0, 11);
    }
    
    try {
      if (digits.startsWith('010')) {
        // 휴대폰 번호
        if (digits.length <= 3) return digits;
        if (digits.length <= 7) return '${digits.substring(0, 3)}-${digits.substring(3)}';
        return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
      } else if (digits.startsWith('02')) {
        // 서울 지역번호
        if (digits.length <= 2) return digits;
        if (digits.length <= 5) return '${digits.substring(0, 2)}-${digits.substring(2)}';
        if (digits.length <= 9) return '${digits.substring(0, 2)}-${digits.substring(2, 5)}-${digits.substring(5)}';
        return '${digits.substring(0, 2)}-${digits.substring(2, 6)}-${digits.substring(6)}';
      } else {
        // 기타 지역번호
        if (digits.length <= 3) return digits;
        if (digits.length <= 6) return '${digits.substring(0, 3)}-${digits.substring(3)}';
        return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
      }
    } catch (e) {
      return digits; // 에러 시 숫자만 반환
    }
  }
}