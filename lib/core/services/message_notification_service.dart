import 'dart:async';
import 'package:flutter/material.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/auth/domain/usecases/get_acc_id.dart';
import 'package:merema/features/comms/domain/entities/messages.dart';
import 'package:merema/features/comms/domain/usecases/get_contacts.dart';
import 'package:merema/features/comms/domain/usecases/get_messages.dart';

class MessageNotificationService {
  Timer? _timer;
  final Map<int, String> _lastMessageTimes = {};
  final Duration checkInterval;
  final List<Function(Message)> _listeners = [];

  MessageNotificationService(
      {this.checkInterval = const Duration(seconds: 30)});

  void addListener(Function(Message) listener) {
    _listeners.add(listener);
  }

  void removeListener(Function(Message) listener) {
    _listeners.remove(listener);
  }

  void startPeriodicCheck() {
    _timer?.cancel();
    _timer = Timer.periodic(checkInterval, (timer) async {
      await _checkForNewMessages();
    });
  }

  void stopPeriodicCheck() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _checkForNewMessages() async {
    try {
      final currentUserAccId = await sl<GetAccIdUseCase>().call(null);
      final contactsResult = await sl<GetContactsUseCase>().call(null);

      contactsResult.fold(
        (error) => null,
        (contacts) async {
          for (final contact in contacts.contacts) {
            await _checkContactMessages(contact.accId, currentUserAccId);
          }
        },
      );
    } catch (e) {
      debugPrint('Error checking messages: $e');
    }
  }

  Future<void> _checkContactMessages(
      int contactId, int currentUserAccId) async {
    final messagesResult = await sl<GetMessagesUseCase>().call(contactId);

    messagesResult.fold(
      (error) => null,
      (messages) {
        if (messages.messages.isNotEmpty) {
          final latestMessage = messages.messages.last;

          if (latestMessage.senderId == currentUserAccId) {
            return;
          }

          final lastMessageTime = _lastMessageTimes[contactId];
          if (lastMessageTime == null ||
              latestMessage.sentAt.compareTo(lastMessageTime) > 0) {
            _notifyNewMessage(latestMessage);
            _lastMessageTimes[contactId] = latestMessage.sentAt;
          }
        }
      },
    );
  }

  void _notifyNewMessage(Message message) {
    for (final listener in _listeners) {
      listener(message);
    }
  }

  void dispose() {
    stopPeriodicCheck();
    _listeners.clear();
  }
}
