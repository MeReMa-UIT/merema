import 'package:dartz/dartz.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/features/auth/domain/repositories/auth_repository.dart';
import 'package:merema/features/profile/domain/repositories/profile_repository.dart';

class UpdateProfileUseCase implements UseCase<Either, Map<String, String>> {
  final AuthRepository authRepository;

  UpdateProfileUseCase({required this.authRepository});

  @override
  Future<Either> call(Map<String, String> params) async {
    final token = await authRepository.getToken();
    if (token.isEmpty) {
      return Left(Error());
    }
    final field = params['field'] ?? '';
    final newValue = params['new_value'] ?? '';
    final password = params['password'] ?? '';

    if (field.isEmpty || newValue.isEmpty || password.isEmpty) {
      return Left(Error());
    }

    return await sl<ProfileRepository>().updateProfile(
      token: token,
      field: field,
      newValue: newValue,
      password: password,
    );
  }
}
