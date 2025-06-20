import 'package:dartz/dartz.dart';
import 'package:merema/core/network/dio_client.dart';
import 'package:merema/core/utils/error_handler.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/auth/data/models/auth_req_params.dart';

abstract class AuthApiService {
  Future<Either<ApiError, String>> login(LoginReqParams loginParams);

  Future<Either<ApiError, String>> recovery(RecoveryReqParams recoveryParams);

  Future<Either<ApiError, String>> recoveryConfirm(
      RecoveryConfirmReqParams recoveryConfirmParams);

  Future<Either<ApiError, String>> recoveryReset(
      RecoveryResetReqParams recoveryResetParams);
}

class AuthApiServiceImpl implements AuthApiService {
  @override
  Future<Either<ApiError, String>> login(LoginReqParams loginParams) async {
    try {
      final response = await sl<DioClient>().post(
        '/accounts/login',
        data: loginParams.toJson(),
      );

      return Right(response.data['token']);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<ApiError, String>> recovery(
      RecoveryReqParams recoveryParams) async {
    try {
      await sl<DioClient>().post(
        '/accounts/recovery',
        data: recoveryParams.toJson(),
      );

      return const Right('Verification code sent');
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<ApiError, String>> recoveryConfirm(
      RecoveryConfirmReqParams recoveryConfirmParams) async {
    try {
      final response = await sl<DioClient>().post(
        '/accounts/recovery/verify',
        data: recoveryConfirmParams.toJson(),
      );

      return Right(response.data['token']);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<ApiError, String>> recoveryReset(
      RecoveryResetReqParams recoveryResetParams) async {
    try {
      await sl<DioClient>().put(
        '/accounts/recovery/reset',
        data: recoveryResetParams.toJson(),
        headers: {
          'Authorization': 'Bearer ${recoveryResetParams.token}',
        },
      );
      return const Right('Password reset successfully');
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }
}
