import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const String CACHED_CONTACTS = 'cached_contacts';
const String CACHED_MESSAGES_PREFIX = 'cached_messages_';

abstract class CommsLocalService {
  Future<void> cacheConversationsFromWs(
      List<Map<String, dynamic>> conversations);
  Future<void> cacheMessagesFromWs(
      int conversationId, List<Map<String, dynamic>> messages);
  Future<List<Map<String, dynamic>>> getCachedConversations();
  Future<List<Map<String, dynamic>>> getCachedMessages(int conversationId);
}

class CommsLocalServiceImpl implements CommsLocalService {
  @override
  Future<void> cacheConversationsFromWs(
      List<Map<String, dynamic>> conversations) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(
      CACHED_CONTACTS,
      json.encode(conversations),
    );
  }

  @override
  Future<void> cacheMessagesFromWs(
      int conversationId, List<Map<String, dynamic>> messages) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(
      '$CACHED_MESSAGES_PREFIX$conversationId',
      json.encode(messages),
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getCachedConversations() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final cachedData = sharedPreferences.getString(CACHED_CONTACTS);
    if (cachedData != null) {
      final List<dynamic> decoded = json.decode(cachedData);
      return List<Map<String, dynamic>>.from(decoded);
    }
    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> getCachedMessages(
      int conversationId) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final cachedData =
        sharedPreferences.getString('$CACHED_MESSAGES_PREFIX$conversationId');
    if (cachedData != null) {
      final List<dynamic> decoded = json.decode(cachedData);
      return List<Map<String, dynamic>>.from(decoded);
    }
    return [];
  }
}
