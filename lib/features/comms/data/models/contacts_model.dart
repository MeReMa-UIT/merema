import 'package:merema/features/comms/domain/entities/contacts.dart';

class ContactModel extends Contact {
  const ContactModel({
    required super.accId,
    required super.fullName,
    required super.role,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      accId: json['acc_id'],
      fullName: json['full_name'],
      role: json['role'],
    );
  }
}

class ContactsModel extends Contacts {
  const ContactsModel({
    required super.contacts,
  });

  factory ContactsModel.fromJson(List<dynamic> json) {
    final contactsList =
        json.map((contactJson) => ContactModel.fromJson(contactJson)).toList();

    return ContactsModel(
      contacts: contactsList,
    );
  }
}
