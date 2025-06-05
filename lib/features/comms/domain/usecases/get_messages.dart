import 'package:dartz/dartz.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/features/auth/domain/repositories/auth_repository.dart';
import 'package:merema/features/comms/domain/repositories/comms_repository.dart';

class GetMessagesUseCase implements UseCase<Either, int> {
  final AuthRepository authRepository;

  GetMessagesUseCase({required this.authRepository});

  @override
  Future<Either> call(int contactId) async {
    final token = await authRepository.getToken();

    if (token.isEmpty) {
      return Left(Error());
    }

    return await sl<CommsRepository>().getMessages(contactId, token);
  }
}
