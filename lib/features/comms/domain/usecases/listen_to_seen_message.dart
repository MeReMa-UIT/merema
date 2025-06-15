import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/comms/domain/repositories/comms_repository.dart';

class ListenToSeenMessageUseCase {
  Stream<Map<String, dynamic>> call() {
    return sl<CommsRepository>().onSeenMessage;
  }
}
