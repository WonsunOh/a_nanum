// lib/core/utils/validator.dart
import '../constants/app_constants.dart';

class Validators {
  // 이메일 검증
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return '이메일을 입력해주세요.';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return '올바른 이메일 형식이 아닙니다.';
    }
    
    return null;
  }
  
  // 비밀번호 검증
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요.';
    }
    
    if (value.length < 8) {
      return '비밀번호는 8자 이상이어야 합니다.';
    }
    
    if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(value)) {
      return '비밀번호는 영문과 숫자를 포함해야 합니다.';
    }
    
    return null;
  }
  
  // 상품명 검증
  static String? productName(String? value) {
    if (value == null || value.isEmpty) {
      return '상품명을 입력해주세요.';
    }
    
    if (value.length < 2) {
      return '상품명은 2자 이상이어야 합니다.';
    }
    
    if (value.length > 100) {
      return '상품명은 100자 이하여야 합니다.';
    }
    
    return null;
  }
  
  // 가격 검증
  static String? price(String? value) {
    if (value == null || value.isEmpty) {
      return '가격을 입력해주세요.';
    }
    
    final price = int.tryParse(value.replaceAll(',', ''));
    if (price == null) {
      return '올바른 가격을 입력해주세요.';
    }
    
    if (price <= 0) {
      return '가격은 0원보다 커야 합니다.';
    }
    
    if (price > AppConstants.maxPrice) {
      return '가격이 너무 높습니다.';
    }
    
    return null;
  }
}