abstract class CommsRepository {
  Future<void> openConnection(String token);
  Future<void> closeConnection();

  Stream<Map<String, dynamic>> get onNewMessage;
  Stream<Map<String, dynamic>> get onMessageHistory;
  Stream<Map<String, dynamic>> get onConversationList;

  Future<void> sendMessage({
    required int partnerAccId,
    required String text,
    required int conversationId,
  });

  Future<void> loadHistory({
    required int conversationId,
    int? limit,
    int? offset,
  });

  Future<void> markSeenMessage({
    required int partnerAccId,
    required String readTime,
    required int conversationId,
  });

  Future<List<Map<String, dynamic>>> getMessages(int conversationId,
      {int? limit, int? offset});
  Future<List<Map<String, dynamic>>> getContacts();

  List<Map<String, dynamic>> get cachedConversations;
}
