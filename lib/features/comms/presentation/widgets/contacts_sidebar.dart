import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/layers/presentation/widgets/app_field.dart';
import 'package:merema/core/layers/presentation/widgets/app_button.dart';
import 'package:merema/core/theme/app_pallete.dart';
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
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Contacts',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppPallete.textColor,
                ),
              ),
              const SizedBox(height: 16),
              AppField(
                labelText: 'Search contacts',
                controller: _searchController,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Clear',
                      onPressed: _onClear,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: 'Search',
                      onPressed: _onSearch,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<ContactsCubit, ContactsState>(
            builder: (context, state) {
              if (state is ContactsLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppPallete.primaryColor,
                  ),
                );
              } else if (state is ContactsError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppPallete.errorColor,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          state.message,
                          style: const TextStyle(
                            color: AppPallete.errorColor,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: AppButton(
                          text: 'Retry',
                          onPressed: () =>
                              context.read<ContactsCubit>().getContacts(),
                        ),
                      ),
                    ],
                  ),
                );
              } else if (state is ContactsLoaded) {
                if (state.filteredContacts.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.contacts_outlined,
                          color: AppPallete.lightGrayColor,
                          size: 64,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No contacts found',
                          style: TextStyle(
                            color: AppPallete.darkGrayColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: state.filteredContacts.length,
                  itemBuilder: (context, index) {
                    final contact = state.filteredContacts[index];
                    final isSelected =
                        widget.selectedContactId == contact.accId;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      color:
                          isSelected ? AppPallete.primaryColor : Colors.white,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? AppPallete.backgroundColor
                              : AppPallete.secondaryColor,
                          child: Text(
                            contact.fullName.isNotEmpty
                                ? contact.fullName[0].toUpperCase()
                                : '',
                            style: TextStyle(
                              color: isSelected
                                  ? AppPallete.primaryColor
                                  : AppPallete.textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          contact.fullName,
                          style: TextStyle(
                            color: AppPallete.textColor,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Role: ${contact.role}',
                              style: const TextStyle(
                                color: AppPallete.darkGrayColor,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'ID: ${contact.accId}',
                              style: const TextStyle(
                                color: AppPallete.darkGrayColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        trailing: Icon(
                          isSelected
                              ? Icons.keyboard_arrow_right
                              : Icons.arrow_forward_ios,
                          color: isSelected
                              ? AppPallete.textColor
                              : AppPallete.lightGrayColor,
                        ),
                        onTap: () {
                          widget.onContactSelected(
                              contact.accId, contact.fullName);
                        },
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}
