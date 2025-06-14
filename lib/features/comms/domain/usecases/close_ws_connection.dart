import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/comms/domain/repositories/comms_repository.dart';

class CloseWsConnectionUseCase implements UseCase<void, dynamic> {
  @override
  Future<void> call(dynamic params) async {
    await sl<CommsRepository>().closeConnection();
  }
}
