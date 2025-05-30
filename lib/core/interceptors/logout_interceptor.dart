import 'package:dio/dio.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/auth/domain/repositories/auth_repository.dart';

class LogoutInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await sl<AuthRepository>().logout(); // TODO: Fix clean architecture violation
    }
    return handler.next(err);
  }
}
