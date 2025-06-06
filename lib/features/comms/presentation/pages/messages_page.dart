import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/features/comms/presentation/bloc/contacts_state_cubit.dart';
import 'package:merema/features/comms/presentation/bloc/messages_state_cubit.dart';
import 'package:merema/features/comms/presentation/widgets/contacts_sidebar.dart';
import 'package:merema/features/comms/presentation/widgets/messages_view.dart';

class MessagesPage extends StatefulWidget {
  final int? contactId;
  final String? contactName;

  const MessagesPage({
    super.key,
    this.contactId,
    this.contactName,
  });

  static Route route({int? contactId, String? contactName}) =>
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => ContactsCubit()..getContacts(),
            ),
            BlocProvider(
              create: (context) => MessagesCubit(),
            ),
          ],
          child: MessagesPage(
            contactId: contactId,
            contactName: contactName,
          ),
        ),
      );

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int? _selectedContactId;
  String? _selectedContactName;

  @override
  void initState() {
    super.initState();
    if (widget.contactId != null && widget.contactName != null) {
      _selectedContactId = widget.contactId;
      _selectedContactName = widget.contactName;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<MessagesCubit>().getMessages(widget.contactId!);
      });
    }
  }

  void _onContactSelected(int contactId, String contactName) {
    setState(() {
      _selectedContactId = contactId;
      _selectedContactName = contactName;
    });

    context.read<MessagesCubit>().getMessages(contactId);

    if (_scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_selectedContactName ?? 'Messages'),
        backgroundColor: AppPallete.backgroundColor,
        foregroundColor: AppPallete.textColor,
        leading: isLargeScreen
            ? (Navigator.of(context).canPop()
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: BackButton(),
                  )
                : null)
            : (Navigator.of(context).canPop()
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: BackButton(),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
                    ),
                  )),
        automaticallyImplyLeading: false,
        actions: !isLargeScreen
            ? [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: IconButton(
                    icon: const Icon(Icons.contacts),
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                ),
              ]
            : null,
      ),
      drawer: isLargeScreen
          ? null
          : Drawer(
              backgroundColor: AppPallete.backgroundColor,
              child: ContactsSidebar(
                onContactSelected: _onContactSelected,
                selectedContactId: _selectedContactId,
              ),
            ),
      backgroundColor: AppPallete.backgroundColor,
      body: isLargeScreen
          ? Row(
              children: [
                SizedBox(
                  width: 350,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: AppPallete.lightGrayColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                    ),
                    child: ContactsSidebar(
                      onContactSelected: _onContactSelected,
                      selectedContactId: _selectedContactId,
                    ),
                  ),
                ),
                Expanded(
                  child:
                      _selectedContactId != null && _selectedContactName != null
                          ? MessagesView(
                              contactId: _selectedContactId!,
                              contactName: _selectedContactName!,
                            )
                          : const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline,
                                    color: AppPallete.lightGrayColor,
                                    size: 64,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Select a contact to start messaging',
                                    style: TextStyle(
                                      color: AppPallete.darkGrayColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                ),
              ],
            )
          : _selectedContactId != null && _selectedContactName != null
              ? MessagesView(
                  contactId: _selectedContactId!,
                  contactName: _selectedContactName!,
                )
              : const Center(
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
                        'Open contacts to start messaging',
                        style: TextStyle(
                          color: AppPallete.darkGrayColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
