import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/comms/domain/usecases/get_messages.dart';
import 'package:merema/features/comms/domain/usecases/send_message.dart';
import 'package:merema/features/comms/presentation/bloc/messages_state.dart';

class MessagesCubit extends Cubit<MessagesState> {
  MessagesCubit() : super(MessagesInitial());

  Future<void> getMessages(int contactId) async {
    emit(MessagesLoading());

    final result = await sl<GetMessagesUseCase>().call(contactId);

    result.fold(
      (error) => emit(MessagesError(error.toString())),
      (messagesData) {
        final messages = messagesData.messages;
        emit(MessagesLoaded(
          messages: messages,
        ));
      },
    );
  }

  Future<void> sendMessage(String content, int contactId) async {
    final result =
        await sl<SendMessageUseCase>().call(Tuple2(content, contactId));

    result.fold(
      (error) => emit(MessagesError(error.toString())),
      (success) => getMessages(contactId),
    );
  }
}
