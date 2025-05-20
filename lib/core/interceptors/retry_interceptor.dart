import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:async';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration retryDelay;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 2),
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      final attempt = err.requestOptions.extra['retry_attempt'] as int? ?? 0;
      if (attempt < maxRetries) {
        err.requestOptions.extra['retry_attempt'] = attempt + 1;

        debugPrint(
            'Retrying request to ${err.requestOptions.path}, attempt #${attempt + 1}');

        await Future.delayed(retryDelay);

        try {
          final response = await dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (e) {
          return super.onError(e is DioException ? e : err, handler);
        }
      } else {
        debugPrint(
            'Max retries reached for request to ${err.requestOptions.path}');
      }
    }
    super.onError(err, handler);
  }

  bool _shouldRetry(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      return true;
    }
    if (err.error is SocketException) {
      return true;
    }
    if (err.response?.statusCode == 503 || err.response?.statusCode == 504) {
      return true;
    }
    if (err.response?.statusCode == 401) {
      return false;
    }
    return false;
  }
}
