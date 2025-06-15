import 'package:flutter/material.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/services/notification_service.dart';
import 'package:merema/features/auth/domain/usecases/get_acc_id.dart';
import 'package:merema/features/comms/domain/usecases/open_ws_connection.dart';
import 'package:merema/features/comms/domain/usecases/close_ws_connection.dart';
import 'package:merema/features/comms/domain/usecases/mark_seen_message.dart';
import 'package:merema/features/comms/domain/usecases/listen_to_message_history.dart';
import 'package:merema/features/comms/domain/usecases/listen_to_new_message.dart';
import 'package:merema/features/comms/domain/usecases/listen_to_seen_message.dart';
import 'package:merema/features/comms/domain/usecases/get_messages.dart';
import 'package:merema/features/comms/domain/usecases/get_contacts.dart';
import 'package:merema/features/comms/domain/entities/mark_seen_message_params.dart';
import 'package:merema/core/layers/domain/entities/user_role.dart';
import 'package:merema/features/comms/presentation/pages/messages_page.dart';
import 'dart:async';

class CommsNotifier extends ChangeNotifier {
  bool _isConnected = false;
  List<Map<String, dynamic>> _newMessages = [];
  final Set<int> _conversationsWithUnreadMessages = {};
  Timer? _debounceTimer;
  int? _currentUserAccId;
  int? _activeConversationId;

  bool get isConnected => _isConnected;
  List<Map<String, dynamic>> get newMessages => _newMessages;
  Set<int> get conversationsWithUnreadMessages =>
      _conversationsWithUnreadMessages;

  Future<void> openConnectionForRole(UserRole role) async {
    if (role == UserRole.doctor || role == UserRole.patient) {
      try {
        _currentUserAccId = await sl<GetAccIdUseCase>().call(null);
        await sl<OpenWsConnectionUseCase>().call(null);
        _isConnected = true;
        _setupMessageListener();
        await _loadAndCheckMessageHistory();
        notifyListeners();
      } catch (e) {
        debugPrint('Failed to open WebSocket connection: $e');
      }
    }
  }

  Future<void> _loadAndCheckMessageHistory() async {
    try {
      final contacts = await sl<GetContactsUseCase>().call(null);

      for (final contact in contacts) {
        try {
          final messages =
              await sl<GetMessagesUseCase>().call(contact.conversationId);

          for (int i = messages.length - 1; i >= 0; i--) {
            final message = messages[i];
            if (message.senderAccId != _currentUserAccId && !message.isSeen) {
              _conversationsWithUnreadMessages.add(contact.conversationId);
              break;
            }
          }
        } catch (e) {
          debugPrint(
              'Error loading messages for conversation ${contact.conversationId}: $e');
        }
      }
    } catch (e) {
      debugPrint('Error loading message history: $e');
    }
  }

  void _setupMessageListener() {
    sl<ListenToMessageHistoryUseCase>().call().listen((event) {
      if (event.containsKey('messages')) {
        final messages = event['messages'];
        if (messages is List) {
          _newMessages = List<Map<String, dynamic>>.from(messages);

          _debounceTimer?.cancel();
          _debounceTimer = Timer(const Duration(milliseconds: 300), () {
            notifyListeners();
          });
        }
      }
    });

    sl<ListenToNewMessageUseCase>().call().listen((event) {
      if (event.containsKey('message')) {
        final message = event['message'];
        if (message is Map<String, dynamic>) {
          _newMessages = [message];

          final conversationId = message['conversation_id'];
          final senderAccId = message['sender_acc_id'];
          final isSeen = message['is_seen'] ?? false;
          if (conversationId is int && senderAccId is int) {
            if (senderAccId != _currentUserAccId && !isSeen) {
              _conversationsWithUnreadMessages.add(conversationId);

              _showNotificationForMessage(message);
            }
          }

          _debounceTimer?.cancel();
          _debounceTimer = Timer(const Duration(milliseconds: 300), () {
            notifyListeners();
          });
        }
      }
    });

    sl<ListenToSeenMessageUseCase>().call().listen((event) {
      if (event.containsKey('conversation_id') &&
          event.containsKey('read_time')) {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 300), () {
          notifyListeners();
        });
      }
    });
  }

  Future<void> closeConnection() async {
    try {
      _debounceTimer?.cancel();
      await sl<CloseWsConnectionUseCase>().call(null);
      _isConnected = false;
      _newMessages.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to close WebSocket connection: $e');
    }
  }

  void clearNewMessages() {
    _newMessages.clear();
    notifyListeners();
  }

  void markConversationAsRead(int conversationId) {
    _conversationsWithUnreadMessages.remove(conversationId);
    notifyListeners();
  }

  bool hasUnreadMessagesFromOthers(int conversationId) {
    return _conversationsWithUnreadMessages.contains(conversationId);
  }

  void setActiveConversation(int conversationId) {
    _activeConversationId = conversationId;
  }

  void clearActiveConversation() {
    _activeConversationId = null;
  }

  bool isConversationActive(int conversationId) {
    return _activeConversationId == conversationId;
  }

  Future<void> markMessagesAsSeen({
    required int partnerAccId,
    required int conversationId,
  }) async {
    if (_currentUserAccId == null) return;

    try {
      final messages = await sl<GetMessagesUseCase>().call(conversationId);
      if (messages.isEmpty) return;
      final newestMessage = messages.last;
      
      if (newestMessage.senderAccId == _currentUserAccId) {
        return;
      }
      if (newestMessage.isSeen) {
        return;
      }

      await sl<MarkSeenMessageUseCase>().call(
        MarkSeenMessageParams(
          partnerAccId: partnerAccId,
          readTime: '${DateTime.now().toIso8601String()}Z',
          conversationId: conversationId,
        ),
      );
      markConversationAsRead(conversationId);
    } catch (e) {
      debugPrint('Error marking messages as seen: $e');
    }
  }

  Future<void> checkAndMarkMessagesAsSeen({
    required List<Map<String, dynamic>> messages,
    required int partnerAccId,
    required int conversationId,
  }) async {
    if (messages.isEmpty || _currentUserAccId == null) return;

    final newestMessage = messages.last;
    final senderAccId = newestMessage['sender_acc_id'];
    final isSeen = newestMessage['is_seen'] ?? false;

    if (senderAccId != _currentUserAccId && !isSeen) {
      try {
        await sl<MarkSeenMessageUseCase>().call(
          MarkSeenMessageParams(
            partnerAccId: partnerAccId,
            readTime: '${DateTime.now().toIso8601String()}Z',
            conversationId: conversationId,
          ),
        );
        markConversationAsRead(conversationId);
      } catch (e) {
        debugPrint('Error marking messages as seen: $e');
      }
    }
  }

  void _showNotificationForMessage(Map<String, dynamic> message) async {
    final senderAccId = message['sender_acc_id'] as int;
    final conversationId = message['conversation_id'] as int;
    final content = message['content'] as String? ?? '';

    if (isConversationActive(conversationId)) {
      return;
    }

    try {
      final contacts = await sl<GetContactsUseCase>().call(null);
      final senderContact =
          contacts.where((c) => c.partnerAccId == senderAccId).firstOrNull;

      final partnerName = senderContact?.partnerName ?? 'Unknown';

      NotificationService().showMessageNotification(
        senderName: partnerName,
        messageContent: content,
      );
    } catch (e) {
      debugPrint('Error getting contact info: $e');
    }
  }

  void navigateToMessagesWithSender(
    BuildContext context,
    int contactId,
    String contactName,
    int conversationId,
  ) {
    Navigator.of(context).push(
      MessagesPage.route(
        contactId: contactId,
        contactName: contactName,
      ),
    );
  }
}
