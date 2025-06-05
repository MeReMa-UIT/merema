import 'dart:convert';
import 'package:merema/features/comms/data/models/contacts_model.dart';
import 'package:merema/features/comms/data/models/messages_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class CommsLocalService {
  Future<ContactsModel?> getCachedContacts();
  Future<void> cacheContacts(ContactsModel contacts);
  Future<MessagesModel?> getCachedMessages(int contactId);
  Future<void> cacheMessages(int contactId, MessagesModel messages);
}

class CommsLocalServiceImpl implements CommsLocalService {
  static const String CACHED_CONTACTS = 'CACHED_CONTACTS';
  static const String CACHED_MESSAGES_PREFIX = 'CACHED_MESSAGES_';

  @override
  Future<ContactsModel?> getCachedContacts() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final jsonString = sharedPreferences.getString(CACHED_CONTACTS);
    return jsonString != null
        ? ContactsModel.fromJson(json.decode(jsonString))
        : null;
  }

  @override
  Future<void> cacheContacts(ContactsModel contacts) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(
      CACHED_CONTACTS,
      json.encode(contacts.contacts
          .map((contact) => {
                'acc_id': contact.accId,
                'full_name': contact.fullName,
                'role': contact.role,
              })
          .toList()),
    );
  }

  @override
  Future<MessagesModel?> getCachedMessages(int contactId) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final jsonString =
        sharedPreferences.getString('$CACHED_MESSAGES_PREFIX$contactId');
    return jsonString != null
        ? MessagesModel.fromJson(json.decode(jsonString))
        : null;
  }

  @override
  Future<void> cacheMessages(int contactId, MessagesModel messages) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(
      '$CACHED_MESSAGES_PREFIX$contactId',
      json.encode(messages.toJson()),
    );
  }
}
