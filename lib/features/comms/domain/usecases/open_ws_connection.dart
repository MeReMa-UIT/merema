import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/features/auth/domain/repositories/auth_repository.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/comms/domain/repositories/comms_repository.dart';

class OpenWsConnectionUseCase implements UseCase<CommsRepository, dynamic> {
  final AuthRepository authRepository;

  OpenWsConnectionUseCase({required this.authRepository});

  @override
  Future<CommsRepository> call(dynamic params) async {
    final token = await authRepository.getToken();
    await sl<CommsRepository>().openConnection(token);
    return sl<CommsRepository>();
  }
}
