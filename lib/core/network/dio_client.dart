// TODO: Add network checker

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:merema/core/consts/consts.dart';
import 'dart:async';
import 'package:merema/core/interceptors/retry_interceptor.dart';
import 'package:merema/core/interceptors/logout_interceptor.dart';

class DioClient {
  late Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Consts.apiBaseUrl,
        connectTimeout: const Duration(seconds: Consts.timeout),
        receiveTimeout: const Duration(seconds: Consts.timeout),
        sendTimeout: const Duration(seconds: Consts.timeout),
        responseType: ResponseType.json,
      ),
    );

    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    _dio.interceptors.add(RetryInterceptor(dio: _dio));

    _dio.interceptors.add(LogoutInterceptor());

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: true,
          error: true,
          logPrint: (object) {
            debugPrint(object.toString());
          },
        ),
      );
    }
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) {
    return _dio.get(
      path,
      queryParameters: queryParameters,
      options: Options(headers: headers),
    );
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) {
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: Options(headers: headers),
    );
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) {
    return _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: Options(headers: headers),
    );
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) {
    return _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: Options(headers: headers),
    );
  }
}
