import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:merema/core/utils/service_locator.dart';
import 'package:merema/features/auth/data/source/auth_local_service.dart';
import 'package:merema/features/auth/domain/repository/auth_repository.dart';
import 'package:merema/features/auth/data/models/auth_req_params.dart';
import 'package:merema/features/auth/data/source/auth_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepositoryImpl extends AuthRepository {
  @override
  Future<Either<Error, String>> login(LoginReqParams loginParams) async {
    Either result = await sl<AuthApiService>().login(loginParams);

    return result.fold(
      (error) {
        return Left(error);
      },
      (token) async {
        Response response = token;
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        sharedPreferences.setString('token', response.data['token']);
        return Right(response.data['token']);
      },
    );
  }

  @override
  Future<Either<Error, String>> recovery(
      RecoveryReqParams recoveryParams) async {
    return sl<AuthApiService>().recovery(recoveryParams);
  }

  @override
  Future<Either<Error, String>> recoveryConfirm(
      RecoveryConfirmReqParams recoveryConfirmParams) async {
    return sl<AuthApiService>().recoveryConfirm(recoveryConfirmParams);
  }

  @override
  Future<Either<Error, String>> recoveryReset(
      RecoveryResetReqParams recoveryResetParams) async {
    return sl<AuthApiService>().recoveryReset(recoveryResetParams);
  }

  @override
  Future<bool> isLoggedIn() async {
    return await sl<AuthLocalService>().isLoggedIn();
  }
}
