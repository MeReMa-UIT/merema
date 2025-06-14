import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/comms/domain/usecases/get_contacts.dart';
import 'package:merema/features/comms/presentation/bloc/contacts_state.dart';

class ContactsCubit extends Cubit<ContactsState> {
  ContactsCubit() : super(ContactsInitial());

  Future<void> getContacts() async {
    if (isClosed) return;

    emit(ContactsLoading());

    try {
      final contacts = await sl<GetContactsUseCase>().call(null);
      if (!isClosed) {
        emit(ContactsLoaded(
          contacts: contacts,
          filteredContacts: List.from(contacts),
        ));
      }
    } catch (error) {
      if (!isClosed) {
        emit(ContactsError(error.toString()));
      }
    }
  }

  void searchContacts({required String searchQuery}) {
    if (isClosed) return;

    final currentState = state;
    if (currentState is ContactsLoaded) {
      if (searchQuery.isEmpty) {
        emit(currentState.copyWith(
          filteredContacts: currentState.contacts,
          searchQuery: searchQuery,
        ));
      } else {
        final filteredContacts = currentState.contacts.where((contact) {
          final partnerName = contact.partnerName.toLowerCase();
          final query = searchQuery.toLowerCase();
          return partnerName.contains(query);
        }).toList();

        emit(currentState.copyWith(
          filteredContacts: filteredContacts,
          searchQuery: searchQuery,
        ));
      }
    }
  }

  void clearSearch() {
    if (isClosed) return;

    final currentState = state;
    if (currentState is ContactsLoaded) {
      emit(currentState.copyWith(
        filteredContacts: currentState.contacts,
        searchQuery: '',
      ));
    }
  }
}
