import 'package:dartz/dartz.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/features/auth/domain/repositories/auth_repository.dart';
import 'package:merema/features/comms/domain/repositories/comms_repository.dart';

class SendMessageUseCase implements UseCase<Either, Tuple2<String, int>> {
  final AuthRepository authRepository;

  SendMessageUseCase({required this.authRepository});

  @override
  Future<Either> call(Tuple2<String, int> params) async {
    final token = await authRepository.getToken();

    if (token.isEmpty) {
      return Left(Error());
    }

    return await sl<CommsRepository>().sendMessage(
      params.value1,
      params.value2,
      token,
    );
  }
}
