import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/comms/domain/usecases/send_message.dart';
import 'package:merema/features/comms/domain/usecases/get_messages.dart';
import 'package:merema/features/comms/presentation/bloc/messages_state.dart';
import 'package:merema/features/comms/presentation/notifiers/comms_notifier.dart';
import 'package:merema/features/comms/domain/entities/send_message_params.dart';
import 'package:merema/features/comms/domain/entities/messages.dart';
import 'dart:async';

class MessagesCubit extends Cubit<MessagesState> {
  final CommsNotifier _commsNotifier = sl<CommsNotifier>();
  int? _currentConversationId;
  VoidCallback? _listener;

  MessagesCubit() : super(MessagesInitial()) {
    _setupCommsListener();
  }

  void _setupCommsListener() {
    _listener = () {
      if (_commsNotifier.newMessages.isNotEmpty &&
          _currentConversationId != null &&
          !isClosed) {
        if (state is! MessagesLoading) {
          getMessages(_currentConversationId!);
        }
        _commsNotifier.clearNewMessages();
      }
    };
    _commsNotifier.addListener(_listener!);
  }

  Future<void> getMessages(int conversationId) async {
    if (isClosed) return;

    if (state is MessagesLoading && _currentConversationId == conversationId) {
      return;
    }

    _currentConversationId = conversationId;
    emit(MessagesLoading());
    try {
      final messages = await sl<GetMessagesUseCase>().call(conversationId);
      if (!isClosed) {
        emit(MessagesLoaded(messages: messages));
      }
    } catch (error) {
      if (!isClosed) {
        emit(MessagesError(error.toString()));
      }
    }
  }

  Future<void> getMessagesFromData({
    required List<Map<String, dynamic>> messagesData,
  }) async {
    if (isClosed) return;

    emit(MessagesLoading());
    try {
      final messages = messagesData.map((e) => Message.fromMap(e)).toList();
      if (!isClosed) {
        emit(MessagesLoaded(messages: messages));
      }
    } catch (error) {
      if (!isClosed) {
        emit(MessagesError(error.toString()));
      }
    }
  }

  Future<void> sendMessage(SendMessageParams params) async {
    if (isClosed) return;

    try {
      await sl<SendMessageUseCase>().call(params);
      if (!isClosed) {
        await getMessages(params.conversationId);
      }
    } catch (error) {
      if (!isClosed) {
        emit(MessagesError(error.toString()));
      }
    }
  }

  @override
  Future<void> close() {
    if (_listener != null) {
      _commsNotifier.removeListener(_listener!);
    }
    return super.close();
  }
}
