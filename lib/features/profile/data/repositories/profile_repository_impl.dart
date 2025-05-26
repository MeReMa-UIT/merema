import 'package:dartz/dartz.dart';
import 'package:merema/core/services/service_locator.dart';
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
            return Left(Error());
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
      return Left(Error());
    }
  }
}
