import 'package:merema/features/comms/data/sources/comms_websocket_service.dart';
import 'package:merema/features/comms/domain/repositories/comms_repository.dart';
import 'package:merema/features/comms/data/sources/comms_local_service.dart';
import 'package:merema/core/services/service_locator.dart';

class CommsRepositoryImpl extends CommsRepository {
  List<Map<String, dynamic>> _cachedConversations = [];
  final Map<int, List<Map<String, dynamic>>> _cachedMessages = {};

  CommsRepositoryImpl();

  @override
  Future<void> openConnection(String token) async {
    sl<CommsWebSocketService>().openConnection(token);
    cacheConversationsFromStream();
  }

  @override
  Future<void> closeConnection() async {
    sl<CommsWebSocketService>().dispose();
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
    List<Map<String, dynamic>> messages = _cachedMessages[conversationId] ?? [];

    _setupMessageHistoryListener(conversationId);

    await loadHistory(
      conversationId: conversationId,
      limit: limit ?? 20,
      offset: offset ?? 0,
    );

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

  @override
  List<Map<String, dynamic>> get cachedConversations => _cachedConversations;

  @override
  Future<List<Map<String, dynamic>>> getContacts() async {
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
