import 'package:dartz/dartz.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/features/profile/domain/repositories/profile_repository.dart';

class GetUserProfileUseCase implements UseCase<Either, dynamic> {
  @override
  Future<Either> call(dynamic params) async {
    return await sl<ProfileRepository>().getUserProfile();
  }
}
