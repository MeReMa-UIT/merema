import 'package:dartz/dartz.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/utils/error_handler.dart';
import 'package:merema/features/profile/data/sources/profile_local_service.dart';
import 'package:merema/features/profile/domain/entities/user_profile.dart';
import 'package:merema/features/profile/domain/repositories/profile_repository.dart';
import '../sources/profile_api_service.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  @override
  Future<Either<Error, UserProfile>> getUserProfile(String token) async {
    try {
      final result = await sl<ProfileApiService>().fetchUserProfile(token);

      return result.fold(
        (error) async {
          final cachedProfile =
              await sl<ProfileLocalService>().getCachedUserProfile();
          if (cachedProfile != null) {
            return Right(cachedProfile);
          } else {
            return Left(error);
          }
        },
        (profile) async {
          await sl<ProfileLocalService>().cacheUserProfile(profile);
          return Right(profile);
        },
      );
    } catch (e) {
      try {
        final cachedProfile =
            await sl<ProfileLocalService>().getCachedUserProfile();
        if (cachedProfile != null) {
          return Right(cachedProfile);
        }
      } catch (_) {}
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<Error, dynamic>> updateProfile({
    required String token,
    required String field,
    required String newValue,
    required String password,
  }) async {
    try {
      final data = {
        'field': field,
        'new_value': newValue,
        'password': password,
      };
      final result =
          await sl<ProfileApiService>().updateUserProfile(data, token);
      return result.fold(
        (error) => Left(error),
        (response) => Right(response),
      );
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }
}
