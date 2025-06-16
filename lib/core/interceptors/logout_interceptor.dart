import 'package:dio/dio.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/auth/domain/repositories/auth_repository.dart';

class LogoutInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final responseData = err.response?.data;
      if (responseData is Map<String, dynamic>) {
        final message = responseData['message']?.toString().toLowerCase() ?? '';
        final error = responseData['error']?.toString().toLowerCase() ?? '';

        if (message.contains('token') &&
                (message.contains('invalid') || message.contains('expired')) ||
            error.contains('token') &&
                (error.contains('invalid') || error.contains('expired'))) {
          await sl<AuthRepository>()
              .logout();
        }
      }
    }
    return handler.next(err);
  }
}
