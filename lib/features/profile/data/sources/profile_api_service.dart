import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:merema/core/network/dio_client.dart';
import 'package:merema/core/utils/error_handler.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/auth/domain/usecases/get_token.dart';
import 'package:merema/features/profile/data/models/user_profile_model.dart';

abstract class ProfileApiService {
  Future<Either<ApiError, UserProfileModel>> fetchUserProfile();
}

class ProfileApiServiceImpl implements ProfileApiService {
  @override
  Future<Either<ApiError, UserProfileModel>> fetchUserProfile() async {
    try {
      final token = await sl<GetTokenUseCase>().call(null);
      debugPrint('DEBUG: Token retrieved: $token');

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
}
