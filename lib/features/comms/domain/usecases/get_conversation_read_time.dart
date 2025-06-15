import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/comms/domain/repositories/comms_repository.dart';

class GetConversationReadTimeUseCase implements UseCase<String?, int> {
  @override
  Future<String?> call(int conversationId) async {
    return sl<CommsRepository>().getConversationReadTime(conversationId);
  }
}
