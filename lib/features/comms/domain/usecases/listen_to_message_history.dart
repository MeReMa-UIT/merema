import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/comms/domain/repositories/comms_repository.dart';

class ListenToMessageHistoryUseCase {
  Stream<Map<String, dynamic>> call() {
    return sl<CommsRepository>().onMessageHistory;
  }
}
