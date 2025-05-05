import 'package:dio/dio.dart';

class ApiErrorHandler {
  static Error handleError(dynamic error) {
    if (error is DioException) {
      final errorMessage =
          error.response?.data?['error'] ?? 'Network error occurred';
      return ArgumentError(errorMessage);
    } else {
      return ArgumentError('An unexpected error occurred: $error');
    }
  }
}
