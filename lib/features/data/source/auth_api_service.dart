import 'package:dartz/dartz.dart';
import 'package:merema/core/network/dio_client.dart';
import 'package:merema/core/utils/error_handler.dart';
import 'package:merema/core/utils/service_locator.dart';
import 'package:merema/features/data/models/auth_req_params.dart';

abstract class AuthApiService {
  Future<Either<Error, String>> login(LoginReqParams loginParams);

  Future<Either<Error, String>> recovery(RecoveryReqParams recoveryParams);

  Future<Either<Error, String>> recoveryConfirm(
      RecoveryConfirmReqParams recoveryConfirmParams);

  Future<Either<Error, String>> recoveryReset(
      RecoveryResetReqParams recoveryResetParams);
}

class AuthApiServiceImpl implements AuthApiService {
  @override
  Future<Either<Error, String>> login(LoginReqParams loginParams) async {
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
  Future<Either<Error, String>> recovery(
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
  Future<Either<Error, String>> recoveryConfirm(
      RecoveryConfirmReqParams recoveryConfirmParams) async {
    try {
      await sl<DioClient>().post(
        '/accounts/recovery/confirm',
        data: recoveryConfirmParams.toJson(),
      );

      // TODO: Handle confirmation status
      return const Right('Verification code confirmed');
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<Error, String>> recoveryReset(
      RecoveryResetReqParams recoveryResetParams) async {
    try {
      await sl<DioClient>().post(
        '/accounts/recovery/reset',
        data: recoveryResetParams.toJson(),
      );
      return const Right('Password reset successfully');
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }
}
