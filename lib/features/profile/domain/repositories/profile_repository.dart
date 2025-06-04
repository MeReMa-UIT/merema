import 'package:dartz/dartz.dart';
import 'package:merema/features/profile/domain/entities/user_profile.dart';

abstract class ProfileRepository {
  Future<Either<Error, UserProfile>> getUserProfile(String token);
  Future<Either<Error, dynamic>> updateProfile({
    required String token,
    required String field,
    required String newValue,
    required String password,
  });
}
