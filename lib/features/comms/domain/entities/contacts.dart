class Contact {
  final int accId;
  final String fullName;
  final String role;

  const Contact({
    required this.accId,
    required this.fullName,
    required this.role,
  });
}

class Contacts {
  final List<Contact> contacts;

  const Contacts({
    required this.contacts,
  });
}
