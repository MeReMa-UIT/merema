import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/features/comms/domain/repositories/comms_repository.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/comms/domain/entities/messages.dart';

class GetMessagesUseCase implements UseCase<List<Message>, int> {
  @override
  Future<List<Message>> call(int conversationId) async {
    final rawMessages = await sl<CommsRepository>().getMessages(conversationId);
    return rawMessages.map((e) => Message.fromMap(e)).toList();
  }
}
