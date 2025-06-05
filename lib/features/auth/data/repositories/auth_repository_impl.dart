import 'package:dartz/dartz.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/utils/error_handler.dart';
import 'package:merema/features/auth/data/sources/auth_local_service.dart';
import 'package:merema/features/auth/domain/repositories/auth_repository.dart';
import 'package:merema/features/auth/data/models/auth_req_params.dart';
import 'package:merema/features/auth/data/sources/auth_api_service.dart';
import 'package:merema/features/profile/data/sources/profile_api_service.dart';

class AuthRepositoryImpl extends AuthRepository {
  @override
  Future<Either<Error, String>> login(LoginReqParams loginParams) async {
    try {
      Either result = await sl<AuthApiService>().login(loginParams);
      return result.fold(
        (error) {
          return Left(error);
        },
        (token) async {
          await sl<AuthLocalService>().setToken(token);

          final userProfile =
              await sl<ProfileApiService>().fetchUserProfile(token);

          return userProfile.fold(
            (error) {
              return Left(error);
            },
            (profile) async {
              await sl<AuthLocalService>().setUserRole(profile.role);
              await sl<AuthLocalService>().setUserAccId(profile.accId);
              return Right(token);
            },
          );
        },
      );
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<Error, String>> recovery(
      RecoveryReqParams recoveryParams) async {
    try {
      return await sl<AuthApiService>().recovery(recoveryParams);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<Error, String>> recoveryConfirm(
      RecoveryConfirmReqParams recoveryConfirmParams) async {
    try {
      return await sl<AuthApiService>().recoveryConfirm(recoveryConfirmParams);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<Error, String>> recoveryReset(
      RecoveryResetReqParams recoveryResetParams) async {
    try {
      return await sl<AuthApiService>().recoveryReset(recoveryResetParams);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
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
  Future<int> getUserAccId() async {
    return await sl<AuthLocalService>().getUserAccId();
  }

  @override
  Future<void> logout() {
    return sl<AuthLocalService>().logout();
  }
}
