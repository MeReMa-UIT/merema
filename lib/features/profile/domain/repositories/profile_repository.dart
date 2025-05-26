import 'package:dartz/dartz.dart';
import 'package:merema/features/profile/domain/entities/user_profile.dart';

// TODO: Add update profile method

abstract class ProfileRepository {
  Future<Either<Error, UserProfile>> getUserProfile(String token);
}
