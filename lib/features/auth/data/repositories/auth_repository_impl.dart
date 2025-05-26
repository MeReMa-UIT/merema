import 'package:dartz/dartz.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/auth/data/sources/auth_local_service.dart';
import 'package:merema/features/auth/domain/repositories/auth_repository.dart';
import 'package:merema/features/auth/data/models/auth_req_params.dart';
import 'package:merema/features/auth/data/sources/auth_api_service.dart';

class AuthRepositoryImpl extends AuthRepository {
  @override
  Future<Either<Error, String>> login(LoginReqParams loginParams) async {
    Either result = await sl<AuthApiService>().login(loginParams);
    return result.fold(
      (error) {
        return Left(error);
      },
      (token) async {
        await sl<AuthLocalService>().setToken(token);

        final userRole = await sl<AuthApiService>().fetchUserRole(token);
        return userRole.fold(
          (error) {
            return Left(error);
          },
          (role) async {
            await sl<AuthLocalService>().setUserRole(role);
            return Right(token);
          },
        );
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

  @override
  Future<String> getToken() async {
    return await sl<AuthLocalService>().getToken();
  }

  @override
  Future<String> getUserRole() async {
    return await sl<AuthLocalService>().getUserRole();
  }

  @override
  Future<void> logout() {
    return sl<AuthLocalService>().logout();
  }
}
