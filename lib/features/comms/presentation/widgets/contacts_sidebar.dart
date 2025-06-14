import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/layers/presentation/widgets/people_sidebar.dart';
import 'package:merema/features/comms/presentation/bloc/contacts_state_cubit.dart';
import 'package:merema/features/comms/presentation/bloc/contacts_state.dart';

class ContactsSidebar extends StatefulWidget {
  final Function(int contactId, String contactName) onContactSelected;
  final int? selectedContactId;

  const ContactsSidebar({
    super.key,
    required this.onContactSelected,
    this.selectedContactId,
  });

  @override
  State<ContactsSidebar> createState() => _ContactsSidebarState();
}

class _ContactsSidebarState extends State<ContactsSidebar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    context.read<ContactsCubit>().searchContacts(
          searchQuery: _searchController.text,
        );
  }

  void _onClear() {
    _searchController.clear();
    context.read<ContactsCubit>().clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContactsCubit, ContactsState>(
      builder: (context, state) {
        final contacts = state is ContactsLoaded ? state.filteredContacts : [];
        final isLoading = state is ContactsLoading;
        final hasError = state is ContactsError;
        final errorMessage = state is ContactsError ? state.message : null;
        final selectedContact = state is ContactsLoaded
            ? contacts
                .where((c) => c.partnerAccId == widget.selectedContactId)
                .firstOrNull
            : null;

        return PeopleSidebar(
          title: 'Contacts',
          people: contacts,
          isLoading: isLoading,
          hasError: hasError,
          errorMessage: errorMessage,
          onPersonSelected: (contact) {
            widget.onContactSelected(contact.partnerAccId, contact.partnerName);
          },
          onShowRegisterView: null,
          onRetry: () => context.read<ContactsCubit>().getContacts(),
          onSearch: _onSearch,
          onClearSearch: _onClear,
          searchController: _searchController,
          selectedPerson: selectedContact,
          getPersonId: (contact) => contact.partnerAccId.toString(),
          getPersonName: (contact) => contact.partnerName,
          getPersonSubtitle: (contact) => 'ID: ${contact.partnerAccId}',
          showRegisterButton: false,
        );
      },
    );
  }
}
