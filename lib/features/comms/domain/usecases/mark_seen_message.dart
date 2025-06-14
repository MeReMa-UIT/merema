import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/features/comms/domain/repositories/comms_repository.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/comms/domain/entities/mark_seen_message_params.dart';

class MarkSeenMessageUseCase implements UseCase<void, MarkSeenMessageParams> {
  @override
  Future<void> call(MarkSeenMessageParams params) async {
    await sl<CommsRepository>().markSeenMessage(
      partnerAccId: params.partnerAccId,
      readTime: params.readTime,
      conversationId: params.conversationId,
    );
  }
}
