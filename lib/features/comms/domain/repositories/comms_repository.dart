abstract class CommsRepository {
  Future<void> openConnection(String token);
  Future<void> closeConnection();

  Stream<Map<String, dynamic>> get onNewMessage;
  Stream<Map<String, dynamic>> get onMessageHistory;
  Stream<Map<String, dynamic>> get onConversationList;
  Stream<Map<String, dynamic>> get onSeenMessage;

  Future<void> sendMessage({
    required int partnerAccId,
    required String text,
    required int conversationId,
  });

  Future<void> loadHistory({
    required int conversationId,
  });

  Future<void> markSeenMessage({
    required int partnerAccId,
    required String readTime,
    required int conversationId,
  });

  Future<List<Map<String, dynamic>>> getMessages(int conversationId);
  Future<List<Map<String, dynamic>>> getContacts();

  List<Map<String, dynamic>> get cachedConversations;

  String? getConversationReadTime(int conversationId);
}
