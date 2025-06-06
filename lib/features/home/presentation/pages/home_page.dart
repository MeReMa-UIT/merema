import 'package:flutter/material.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/services/message_notification_service.dart';
import 'package:merema/core/layers/presentation/widgets/desktop_notification.dart';
import 'package:merema/features/auth/domain/usecases/get_user_role.dart';
import 'package:merema/features/auth/domain/usecases/logout.dart';
import 'package:merema/core/layers/domain/entities/user_role.dart';
import 'package:merema/features/comms/domain/entities/messages.dart';
import 'package:merema/features/comms/domain/usecases/get_contacts.dart';
import 'package:merema/features/comms/presentation/pages/messages_page.dart';
import 'package:merema/features/home/presentation/widgets/menu_items_layout.dart';
import 'package:merema/features/prescriptions/presentation/pages/prescriptions_patient_page.dart';
import 'package:merema/features/profile/presentation/pages/profile_page.dart';
import 'package:merema/features/patients/presentation/pages/patients_page.dart';
import 'package:merema/features/schedules/presentation/pages/schedules_page.dart';
import 'package:merema/features/staffs/presentation/pages/staffs_page.dart';

class MenuItemConfig {
  final String title;
  final IconData icon;
  final Function(BuildContext context) onTap;

  MenuItemConfig({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}

final Map<UserRole, List<MenuItemConfig>> _roleBasedMenuItems = {
  // TODO: Implement menu items for each user role
  UserRole.doctor: [
    MenuItemConfig(
        title: 'Patients',
        icon: Icons.people,
        onTap: (context) {
          Navigator.push(context, PatientsPage.route());
        }),
    MenuItemConfig(
        title: 'Messages',
        icon: Icons.message,
        onTap: (context) {
          Navigator.push(context, MessagesPage.route());
        }),
  ],
  UserRole.patient: [
    MenuItemConfig(
        title: 'Medical Records',
        icon: Icons.medical_information,
        onTap: (context) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Medical records unimplemented')));
        }),
    MenuItemConfig(
        title: 'Prescriptions',
        icon: Icons.receipt_long,
        onTap: (context) {
          Navigator.push(context, PrescriptionsPatientPage.route());
        }),
    MenuItemConfig(
        title: 'Schedules',
        icon: Icons.calendar_today,
        onTap: (context) {
          Navigator.push(context, SchedulesPage.route());
        }),
    MenuItemConfig(
        title: 'Messages',
        icon: Icons.message,
        onTap: (context) {
          Navigator.push(context, MessagesPage.route());
        }),
  ],
  UserRole.admin: [
    MenuItemConfig(
        title: 'Staffs',
        icon: Icons.people,
        onTap: (context) {
          Navigator.push(context, StaffsPage.route());
        }),
    MenuItemConfig(
        title: 'Reports',
        icon: Icons.assessment,
        onTap: (context) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reports unimplemented')));
        }),
  ],
  UserRole.receptionist: [
    MenuItemConfig(
        title: 'Patients',
        icon: Icons.people,
        onTap: (context) {
          Navigator.push(context, PatientsPage.route());
        }),
    MenuItemConfig(
        title: 'Schedules',
        icon: Icons.calendar_today,
        onTap: (context) {
          Navigator.push(context, SchedulesPage.route());
        }),
  ],
};

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static Route route() => MaterialPageRoute(
        builder: (context) => const HomePage(),
      );

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  UserRole _currentUserRole = UserRole.noRole;
  bool _isLoadingRole = true;
  MessageNotificationService? _notificationService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _getRole();
  }

  @override
  void dispose() {
    _notificationService?.removeListener(_onNewMessage);
    _notificationService?.stopPeriodicCheck();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _notificationService?.startPeriodicCheck();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _notificationService?.stopPeriodicCheck();
        break;
      default:
        break;
    }
  }

  void _setupNotificationService() {
    if (_currentUserRole == UserRole.doctor ||
        _currentUserRole == UserRole.patient) {
      _notificationService = sl<MessageNotificationService>();
      _notificationService?.addListener(_onNewMessage);
      _notificationService?.startPeriodicCheck();
    }
  }

  void _onNewMessage(Message message) async {
    if (mounted) {
      final contactsResult = await sl<GetContactsUseCase>().call(null);

      if (!mounted) return;

      String senderName = 'Unknown Contact';
      contactsResult.fold(
        (error) => null,
        (contacts) {
          final senderContact = contacts.contacts.firstWhere(
            (contact) => contact.accId == message.senderId,
          );
          senderName = senderContact.fullName;
        },
      );

      DesktopNotificationManager.showNotification(
        context,
        title: 'New Message',
        message: 'You have received a new message from $senderName',
        onTap: () {
          Navigator.push(
            context,
            MessagesPage.route(
              contactId: message.senderId,
              contactName: senderName,
            ),
          );
        },
      );
    }
  }

  Future<void> _getRole() async {
    try {
      final userRole = await sl<GetUserRoleUseCase>().call(null);
      setState(() {
        _currentUserRole = userRole;
        _isLoadingRole = false;
      });
      _setupNotificationService();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRole = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _logout() async {
    await sl<LogoutUseCase>().call(null);
  }

  void _onProfilePressed() {
    Navigator.push(context, ProfilePage.route());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingRole) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final List<MenuItemConfig> currentMenuItems =
        _roleBasedMenuItems[_currentUserRole] ?? [];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.person_outline, size: 30.0),
                    onPressed: _onProfilePressed,
                    tooltip: 'Profile',
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, size: 30.0),
                    onPressed: _logout,
                    tooltip: 'Logout',
                  ),
                ],
              ),
            ),
            MenuItemsLayout(currentMenuItems: currentMenuItems),
          ],
        ),
      ),
    );
  }
}
