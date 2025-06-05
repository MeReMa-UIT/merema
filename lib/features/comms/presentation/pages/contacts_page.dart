import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/layers/presentation/widgets/app_field.dart';
import 'package:merema/core/layers/presentation/widgets/app_button.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/features/comms/presentation/bloc/contacts_state_cubit.dart';
import 'package:merema/features/comms/presentation/bloc/contacts_state.dart';
import 'package:merema/features/comms/presentation/pages/messages_page.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  static Route route() => MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => ContactsCubit()..getContacts(),
          child: const ContactsPage(),
        ),
      );

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        backgroundColor: AppPallete.backgroundColor,
        foregroundColor: AppPallete.textColor,
      ),
      backgroundColor: AppPallete.backgroundColor,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
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
                        Text(
                          state.message,
                          style: const TextStyle(
                            color: AppPallete.errorColor,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
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
                    padding: const EdgeInsets.all(16.0),
                    itemCount: state.filteredContacts.length,
                    itemBuilder: (context, index) {
                      final contact = state.filteredContacts[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        color: Colors.white,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppPallete.secondaryColor,
                            child: Text(
                              contact.fullName.isNotEmpty
                                  ? contact.fullName[0].toUpperCase()
                                  : '',
                              style: const TextStyle(
                                color: AppPallete.textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            contact.fullName,
                            style: const TextStyle(
                              color: AppPallete.textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Role: ${contact.role}',
                                style: const TextStyle(
                                  color: AppPallete.darkGrayColor,
                                ),
                              ),
                              Text(
                                'ID: ${contact.accId}',
                                style: const TextStyle(
                                  color: AppPallete.darkGrayColor,
                                ),
                              ),
                            ],
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: AppPallete.lightGrayColor,
                          ),
                          onTap: () {
                            Navigator.of(context).push(MessagesPage.route(
                              contactId: contact.accId,
                              contactName: contact.fullName,
                            ));
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
      ),
    );
  }
}
