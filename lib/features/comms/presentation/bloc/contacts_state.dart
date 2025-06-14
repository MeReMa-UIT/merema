import 'package:equatable/equatable.dart';
import 'package:merema/features/comms/domain/entities/contact.dart';

abstract class ContactsState extends Equatable {
  const ContactsState();

  @override
  List<Object> get props => [];
}

class ContactsInitial extends ContactsState {}

class ContactsLoading extends ContactsState {}

class ContactsLoaded extends ContactsState {
  final List<Contact> contacts;
  final List<Contact> filteredContacts;
  final String searchQuery;

  const ContactsLoaded({
    required this.contacts,
    required this.filteredContacts,
    this.searchQuery = '',
  });

  @override
  List<Object> get props => [contacts, filteredContacts, searchQuery];

  ContactsLoaded copyWith({
    List<Contact>? contacts,
    List<Contact>? filteredContacts,
    String? searchQuery,
  }) {
    return ContactsLoaded(
      contacts: contacts ?? this.contacts,
      filteredContacts: filteredContacts ?? this.filteredContacts,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ContactsError extends ContactsState {
  final String message;

  const ContactsError(this.message);

  @override
  List<Object> get props => [message];
}
