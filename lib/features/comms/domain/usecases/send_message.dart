import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/features/comms/domain/repositories/comms_repository.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/comms/domain/entities/send_message_params.dart';

class SendMessageUseCase implements UseCase<void, SendMessageParams> {
  @override
  Future<void> call(SendMessageParams params) async {
    await sl<CommsRepository>().sendMessage(
      partnerAccId: params.partnerAccId,
      text: params.text,
      conversationId: params.conversationId,
    );
  }
}
