import 'package:flutter/material.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/auth/domain/usecases/get_user_role.dart';
import 'package:merema/features/auth/domain/usecases/logout.dart';
import 'package:merema/core/layers/domain/entities/user_role.dart';
import 'package:merema/features/home/presentation/widgets/menu_items_layout.dart';
import 'package:merema/features/profile/presentation/pages/profile_page.dart';
import 'package:merema/features/patients/presentation/pages/patients_page.dart';
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
        title: 'Medical Records',
        icon: Icons.medical_information,
        onTap: (context) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Medical records unimplemented')));
        }),
    MenuItemConfig(
        title: 'Patients',
        icon: Icons.people,
        onTap: (context) {
          Navigator.push(context, PatientsPage.route());
        }),
    MenuItemConfig(
        title: 'Prescriptions',
        icon: Icons.receipt_long,
        onTap: (context) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Prescriptions unimplemented')));
        }),
    MenuItemConfig(
        title: 'Messages',
        icon: Icons.message,
        onTap: (context) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Messages unimplemented')));
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
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Prescriptions unimplemented')));
        }),
    MenuItemConfig(
        title: 'Schedule Appointment',
        icon: Icons.calendar_today,
        onTap: (context) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Schedule appointment unimplemented')));
        }),
    MenuItemConfig(
        title: 'Messages',
        icon: Icons.message,
        onTap: (context) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Messages unimplemented')));
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
        title: 'Appointments',
        icon: Icons.calendar_today,
        onTap: (context) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Appointment unimplemented')));
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

class _HomePageState extends State<HomePage> {
  UserRole _currentUserRole = UserRole.noRole;
  bool _isLoadingRole = true;

  @override
  void initState() {
    super.initState();
    _getRole();
  }

  Future<void> _getRole() async {
    try {
      final userRole = await sl<GetUserRoleUseCase>().call(null);
      setState(() {
        _currentUserRole = userRole;
        _isLoadingRole = false;
      });
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
