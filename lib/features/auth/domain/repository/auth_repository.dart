import 'package:dartz/dartz.dart';
import 'package:merema/features/auth/data/models/auth_req_params.dart';

abstract class AuthRepository {
  Future<Either<Error, String>> login(LoginReqParams loginParams);

  Future<Either<Error, String>> recovery(RecoveryReqParams recoveryParams);

  Future<Either<Error, String>> recoveryConfirm(
      RecoveryConfirmReqParams recoveryConfirmParams);

  Future<Either<Error, String>> recoveryReset(
      RecoveryResetReqParams recoveryResetParams);

  Future<bool> isLoggedIn();

  Future<String> getToken();
  Future<String> getUserRole();
}
