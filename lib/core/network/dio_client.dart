import 'package:dio/dio.dart';
import 'package:merema/core/consts/consts.dart';

class DioClient {
  final Dio _dio;

  DioClient() : _dio = Dio() {
    _dio.options = BaseOptions(
      baseUrl: Consts.apiBaseUrl,
      connectTimeout: const Duration(seconds: Consts.timeout),
      receiveTimeout: const Duration(seconds: Consts.timeout),
      sendTimeout: const Duration(seconds: Consts.timeout),
    );
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters, Map<String, dynamic>? headers}) {
    return _dio.get(path,
        queryParameters: queryParameters, options: Options(headers: headers));
  }

  Future<Response> post(String path,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Map<String, dynamic>? headers}) {
    return _dio.post(path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers));
  }

  Future<Response> put(String path,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Map<String, dynamic>? headers}) {
    return _dio.put(path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers));
  }

  Future<Response> delete(String path,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Map<String, dynamic>? headers}) {
    return _dio.delete(path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers));
  }
}
