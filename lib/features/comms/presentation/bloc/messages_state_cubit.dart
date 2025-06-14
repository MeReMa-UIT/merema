import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/comms/domain/usecases/send_message.dart';
import 'package:merema/features/comms/domain/usecases/get_messages.dart';
import 'package:merema/features/comms/presentation/bloc/messages_state.dart';
import 'package:merema/features/comms/presentation/notifiers/comms_notifier.dart';
import 'package:merema/features/comms/domain/entities/send_message_params.dart';
import 'package:merema/features/comms/domain/entities/messages.dart';

class MessagesCubit extends Cubit<MessagesState> {
  final CommsNotifier _commsNotifier = sl<CommsNotifier>();
  int? _currentConversationId;

  MessagesCubit() : super(MessagesInitial()) {
    _setupCommsListener();
  }

  void _setupCommsListener() {
    _commsNotifier.addListener(() {
      if (_commsNotifier.newMessages.isNotEmpty &&
          _currentConversationId != null) {
        getMessages(_currentConversationId!);
        _commsNotifier.clearNewMessages();
      }
    });
  }

  Future<void> getMessages(int conversationId) async {
    _currentConversationId = conversationId;
    emit(MessagesLoading());
    try {
      final messages = await sl<GetMessagesUseCase>().call(conversationId);
      emit(MessagesLoaded(messages: messages));
    } catch (error) {
      emit(MessagesError(error.toString()));
    }
  }

  Future<void> getMessagesFromData({
    required List<Map<String, dynamic>> messagesData,
  }) async {
    emit(MessagesLoading());
    try {
      final messages = messagesData.map((e) => Message.fromMap(e)).toList();
      emit(MessagesLoaded(messages: messages));
    } catch (error) {
      emit(MessagesError(error.toString()));
    }
  }

  Future<void> sendMessage(SendMessageParams params) async {
    try {
      await sl<SendMessageUseCase>().call(params);

      await getMessages(params.conversationId);
    } catch (error) {
      emit(MessagesError(error.toString()));
    }
  }

  @override
  Future<void> close() {
    _commsNotifier.removeListener(() {});
    return super.close();
  }
}
