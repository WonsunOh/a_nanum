// lib/core/utils/result.dart - Result 패턴 도입
import '../../data/models/product_model.dart';
import '../errors/app_exception.dart';

sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final AppException exception;
  const Failure(this.exception);
}

