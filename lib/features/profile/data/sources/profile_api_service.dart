import 'package:dartz/dartz.dart';
import 'package:merema/core/network/dio_client.dart';
import 'package:merema/core/utils/error_handler.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/profile/data/models/user_profile_model.dart';

abstract class ProfileApiService {
  Future<Either<ApiError, UserProfileModel>> fetchUserProfile(String token);
  Future<Either<ApiError, dynamic>> updateUserProfile(
      Map<String, dynamic> data, String token);
}

class ProfileApiServiceImpl implements ProfileApiService {
  @override
  Future<Either<ApiError, UserProfileModel>> fetchUserProfile(
      String token) async {
    try {
      final response = await sl<DioClient>().get(
        '/accounts/profile',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final userProfileModel = UserProfileModel.fromJson(response.data);

      return Right(userProfileModel);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<ApiError, dynamic>> updateUserProfile(
      Map<String, dynamic> data, String token) async {
    try {
      final response = await sl<DioClient>().put(
        '/accounts/profile',
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
