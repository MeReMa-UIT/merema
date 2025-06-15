import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/comms/domain/usecases/send_message.dart';
import 'package:merema/features/comms/domain/usecases/get_messages.dart';
import 'package:merema/features/comms/domain/usecases/get_conversation_read_time.dart';
import 'package:merema/features/comms/domain/usecases/listen_to_seen_message.dart';
import 'package:merema/features/comms/presentation/bloc/messages_state.dart';
import 'package:merema/features/comms/presentation/notifiers/comms_notifier.dart';
import 'package:merema/features/comms/domain/entities/send_message_params.dart';
import 'package:merema/features/comms/domain/entities/messages.dart';
import 'dart:async';

class MessagesCubit extends Cubit<MessagesState> {
  final CommsNotifier _commsNotifier = sl<CommsNotifier>();
  int? _currentConversationId;
  VoidCallback? _listener;
  StreamSubscription? _seenMessageSubscription;
  bool _hasReceivedSeenUpdate = false;

  MessagesCubit() : super(MessagesInitial()) {
    _setupCommsListener();
    _setupSeenMessageListener();
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

  void _setupSeenMessageListener() {
    _seenMessageSubscription =
        sl<ListenToSeenMessageUseCase>().call().listen((event) {
      if (_currentConversationId != null &&
          event.containsKey('conversation_id') &&
          event['conversation_id'] == _currentConversationId &&
          !isClosed) {
        _hasReceivedSeenUpdate = true;
        getMessages(_currentConversationId!);
      }
    });
  }

  Future<bool> isMessageSeen(String messageSentAt, int conversationId) async {
    if (!_hasReceivedSeenUpdate && state is MessagesLoaded) {
      final currentMessages = (state as MessagesLoaded).messages;
      final message = currentMessages
          .where((msg) => msg.sentAt == messageSentAt)
          .firstOrNull;

      if (message != null) {
        return message.isSeen;
      }
    }

    final readTime =
        await sl<GetConversationReadTimeUseCase>().call(conversationId);

    if (readTime == null) {
      return false;
    }

    try {
      String normalizedMessageSentAt = messageSentAt;

      if (!messageSentAt.contains('T') && messageSentAt.contains(' ')) {
        normalizedMessageSentAt = messageSentAt.replaceFirst(' ', 'T');
      }

      final messageTime = DateTime.parse(normalizedMessageSentAt);
      final cleanReadTime = readTime.replaceAll('Z', '');
      final readDateTime = DateTime.parse('$cleanReadTime+07:00');

      final isBeforeOrSame = messageTime.isBefore(readDateTime) ||
          messageTime.isAtSameMomentAs(readDateTime);

      return isBeforeOrSame;
    } catch (e) {
      return false;
    }
  }

  Future<String> getSeenStatus(String messageSentAt) async {
    if (_currentConversationId == null) return '';

    final isRead = await isMessageSeen(messageSentAt, _currentConversationId!);
    return isRead ? 'Seen' : 'Not seen';
  }

  Future<void> getMessages(int conversationId) async {
    if (isClosed) return;

    if (state is MessagesLoading && _currentConversationId == conversationId) {
      return;
    }

    if (_currentConversationId != conversationId) {
      _hasReceivedSeenUpdate = false;
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
    _seenMessageSubscription?.cancel();
    return super.close();
  }
}
