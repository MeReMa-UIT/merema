import 'package:dio/dio.dart';

class ApiError implements Error {
  final String message;
  final int statusCode;
  @override
  final StackTrace? stackTrace;

  ApiError({
    required this.message,
    required this.statusCode,
    this.stackTrace,
  });

  @override
  String toString() => message;
}

class ApiErrorHandler {
  static ApiError handleError(dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode ?? 500;
      final message =
          error.response?.data['message'] ?? 'Unknown error occurred';
      return ApiError(message: message, statusCode: statusCode);
    }

    return ApiError(
      message: error.toString(),
      statusCode: 500,
    );
  }
}
