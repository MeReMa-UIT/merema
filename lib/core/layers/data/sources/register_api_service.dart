import 'package:dartz/dartz.dart';
import 'package:merema/core/network/dio_client.dart';
import 'package:merema/core/utils/error_handler.dart';
import 'package:merema/core/services/service_locator.dart';

abstract class RegisterApiService {
  Future<Either<ApiError, dynamic>> registerAccount(
      Map<String, dynamic> data, String token);
  Future<Either<ApiError, dynamic>> createAccount(
      Map<String, dynamic> data, String token);
}

class RegisterApiServiceImpl implements RegisterApiService {
  @override
  Future<Either<ApiError, dynamic>> registerAccount(
      Map<String, dynamic> data, String token) async {
    try {
      final response = await sl<DioClient>().post(
        '/accounts/register',
        data: data,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return Right(response.data);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<ApiError, dynamic>> createAccount(
      Map<String, dynamic> data, String token) async {
    try {
      final response = await sl<DioClient>().post(
        '/accounts/register/create',
        data: data,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return Right(response.data);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }
}
