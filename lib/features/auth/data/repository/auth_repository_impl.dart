import 'package:dartz/dartz.dart';
import 'package:merema/core/utils/service_locator.dart';
import 'package:merema/features/auth/domain/repository/auth_repository.dart';
import 'package:merema/features/auth/data/models/auth_req_params.dart';
import 'package:merema/features/auth/data/source/auth_api_service.dart';

class AuthRepositoryImpl extends AuthRepository {
  @override
  Future<Either<Error, String>> login(LoginReqParams loginParams) async {
    return sl<AuthApiService>().login(loginParams);
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
}
