import 'package:dartz/dartz.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/features/auth/domain/repositories/auth_repository.dart';
import 'package:merema/features/comms/domain/repositories/comms_repository.dart';

class GetContactsUseCase implements UseCase<Either, dynamic> {
  final AuthRepository authRepository;

  GetContactsUseCase({required this.authRepository});

  @override
  Future<Either> call(dynamic params) async {
    final token = await authRepository.getToken();

    if (token.isEmpty) {
      return Left(Error());
    }

    return await sl<CommsRepository>().getContacts(token);
  }
}
