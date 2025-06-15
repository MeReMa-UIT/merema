import 'package:flutter/foundation.dart';
import 'package:merema/features/comms/data/sources/comms_websocket_service.dart';
import 'package:merema/features/comms/domain/repositories/comms_repository.dart';
import 'package:merema/features/comms/data/sources/comms_local_service.dart';
import 'package:merema/core/services/service_locator.dart';

class CommsRepositoryImpl extends CommsRepository {
  List<Map<String, dynamic>> _cachedConversations = [];
  final Map<int, List<Map<String, dynamic>>> _cachedMessages = {};
  final Set<int> _historyLoaded = {};
  final Map<int, String?> _conversationReadTimes = {};
  bool _isInitialized = false;

  CommsRepositoryImpl();

  Future<void> _initializeFromCache() async {
    if (_isInitialized) return;

    _cachedConversations =
        await sl<CommsLocalService>().getCachedConversations();
    _isInitialized = true;
  }

  @override
  Future<void> openConnection(String token) async {
    sl<CommsWebSocketService>().openConnection(token);
    cacheConversationsFromStream();
    _setupSeenMessageListener();
  }

  @override
  Future<void> closeConnection() async {
    await sl<CommsWebSocketService>().closeConnection();
  }

  @override
  Stream<Map<String, dynamic>> get onConversationList =>
      sl<CommsWebSocketService>()
          .stream
          .where((event) => event['type'] == 'conversationList');

  @override
  Stream<Map<String, dynamic>> get onMessageHistory =>
      sl<CommsWebSocketService>()
          .stream
          .where((event) => event['type'] == 'messageHistory');

  @override
  Stream<Map<String, dynamic>> get onNewMessage => sl<CommsWebSocketService>()
      .stream
      .where((event) => event['type'] == 'newMessage');

  @override
  Stream<Map<String, dynamic>> get onSeenMessage => sl<CommsWebSocketService>()
      .stream
      .where((event) => event['type'] == 'seenMessage');

  void cacheConversationsFromStream() {
    onConversationList.listen((event) async {
      if (event.containsKey('conversations')) {
        final convos = event['conversations'];
        if (convos is List) {
          _cachedConversations = List<Map<String, dynamic>>.from(convos);
          await sl<CommsLocalService>()
              .cacheConversationsFromWs(_cachedConversations);
        }
      }
    });
  }

  Future<void> cacheMessagesFromWs(
      int conversationId, List<Map<String, dynamic>> messages) async {
    final existing = _cachedMessages[conversationId] ?? [];
    final existingTimes = existing.map((m) => m['sent_at']).toSet();
    final newMessages =
        messages.where((m) => !existingTimes.contains(m['sent_at'])).toList();
    if (newMessages.isNotEmpty) {
      _cachedMessages[conversationId] = [...existing, ...newMessages];
      await sl<CommsLocalService>().cacheMessagesFromWs(
          conversationId, _cachedMessages[conversationId]!);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getMessages(int conversationId,
      {int? limit, int? offset}) async {
    await _initializeFromCache();

    if (!_cachedMessages.containsKey(conversationId)) {
      _cachedMessages[conversationId] =
          await sl<CommsLocalService>().getCachedMessages(conversationId);
    }

    List<Map<String, dynamic>> messages = _cachedMessages[conversationId] ?? [];

    _setupMessageHistoryListener(conversationId);
    _setupNewMessageListener(conversationId);

    if (!_historyLoaded.contains(conversationId)) {
      _historyLoaded.add(conversationId);
      await loadHistory(
        conversationId: conversationId,
        limit: limit ?? 50,
        offset: offset ?? 0,
      );
    }

    return List.from(messages);
  }

  void _setupMessageHistoryListener(int conversationId) {
    onMessageHistory.listen((event) async {
      if (event.containsKey('conversation_id') &&
          event['conversation_id'] == conversationId &&
          event.containsKey('messages')) {
        final messages = event['messages'];
        if (messages is List) {
          final messageList = List<Map<String, dynamic>>.from(messages);
          await cacheMessagesFromWs(conversationId, messageList);
        }
      }
    });
  }

  void _setupNewMessageListener(int conversationId) {
    onNewMessage.listen((event) async {
      if (event.containsKey('conversation_id') &&
          event['conversation_id'] == conversationId &&
          event.containsKey('message')) {
        final messageData = event['message'];
        if (messageData is Map<String, dynamic>) {
          final existing = _cachedMessages[conversationId] ?? [];
          final messageId = messageData['message_id'];

          final messageExists =
              existing.any((m) => m['message_id'] == messageId);
          if (!messageExists) {
            _cachedMessages[conversationId] = [...existing, messageData];
            await sl<CommsLocalService>().cacheMessagesFromWs(
                conversationId, _cachedMessages[conversationId]!);
          }
        }
      }
    });
  }

  void _setupSeenMessageListener() {
    onSeenMessage.listen((event) {
      if (event.containsKey('conversation_id') &&
          event.containsKey('read_time')) {
        final conversationId = event['conversation_id'] as int;
        final readTime = event['read_time'] as String;
        _conversationReadTimes[conversationId] = readTime;

        _updateMessagesSeenStatus(conversationId, readTime);
      }
    });
  }

  void _updateMessagesSeenStatus(int conversationId, String readTime) {
    if (!_cachedMessages.containsKey(conversationId)) return;

    try {
      final readDateTime = DateTime.parse(readTime);
      final messages = _cachedMessages[conversationId]!;
      bool hasUpdates = false;

      for (var message in messages) {
        if (message.containsKey('sent_at') && message.containsKey('is_seen')) {
          final sentAt = message['sent_at'] as String;
          final messageDateTime = DateTime.parse(sentAt);

          if ((messageDateTime.isBefore(readDateTime) ||
                  messageDateTime.isAtSameMomentAs(readDateTime)) &&
              message['is_seen'] != true) {
            message['is_seen'] = true;
            hasUpdates = true;
          }
        }
      }

      if (hasUpdates) {
        sl<CommsLocalService>().cacheMessagesFromWs(conversationId, messages);
      }
    } catch (e) {
      debugPrint(
          'Error updating seen status for conversation $conversationId: $e');
    }
  }

  @override
  String? getConversationReadTime(int conversationId) {
    return _conversationReadTimes[conversationId];
  }

  @override
  List<Map<String, dynamic>> get cachedConversations => _cachedConversations;

  @override
  Future<List<Map<String, dynamic>>> getContacts() async {
    await _initializeFromCache();
    return _cachedConversations;
  }

  @override
  Future<void> sendMessage({
    required int partnerAccId,
    required String text,
    required int conversationId,
  }) async {
    sl<CommsWebSocketService>().sendMessage(
      partnerAccId: partnerAccId,
      text: text,
      conversationId: conversationId,
    );
  }

  @override
  Future<void> loadHistory({
    required int conversationId,
    int? limit,
    int? offset,
  }) async {
    sl<CommsWebSocketService>().loadHistory(
      conversationId: conversationId,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<void> markSeenMessage({
    required int partnerAccId,
    required String readTime,
    required int conversationId,
  }) async {
    sl<CommsWebSocketService>().markSeenMessage(
      partnerAccId: partnerAccId,
      readTime: readTime,
      conversationId: conversationId,
    );
  }
}
