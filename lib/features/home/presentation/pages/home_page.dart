import 'package:flutter/material.dart';
import 'package:merema/features/auth/domain/usecases/get_user_role.dart';
import 'package:merema/core/utils/service_locator.dart';
import 'package:merema/features/home/presentation/widgets/menu_items_grid_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:merema/features/auth/presentation/pages/login_page.dart';

enum UserRole {
  admin,
  doctor,
  patient,
  receptionist,
  noRole,
}

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
        title: 'Placeholder1',
        icon: Icons.square,
        onTap: (context) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Unimplemented')));
        }),
    MenuItemConfig(
        title: 'Placeholder2',
        icon: Icons.square,
        onTap: (context) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Unimplemented')));
        }),
    MenuItemConfig(
        title: 'Placeholder3',
        icon: Icons.square,
        onTap: (context) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Unimplemented')));
        }),
    MenuItemConfig(
        title: 'Placeholder4',
        icon: Icons.square,
        onTap: (context) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Unimplemented')));
        }),
    MenuItemConfig(
        title: 'Placeholder5',
        icon: Icons.square,
        onTap: (context) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Unimplemented')));
        }),
    MenuItemConfig(
        title: 'Placeholder6',
        icon: Icons.square,
        onTap: (context) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Unimplemented')));
        }),
  ],
  UserRole.patient: [
    MenuItemConfig(
        title: 'Placeholder7',
        icon: Icons.square,
        onTap: (context) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Unimplemented')));
        }),
  ],
  UserRole.admin: [
    MenuItemConfig(
        title: 'Placeholder8',
        icon: Icons.square,
        onTap: (context) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Unimplemented')));
        }),
  ],
  UserRole.receptionist: [
    MenuItemConfig(
        title: 'Placeholder9',
        icon: Icons.square,
        onTap: (context) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Unimplemented')));
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
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    try {
      final userRole = await sl<GetUserRoleUseCase>().call(null);
      setState(() {
        _currentUserRole = _mapStringToUserRole(userRole);
        _isLoadingRole = false;
      });
    } catch (e) {
      if (mounted) {
        _isLoadingRole = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'An error occured, please restart the app or re-login.')),
        );
      }
    }
  }

  UserRole _mapStringToUserRole(String roleString) {
    switch (roleString.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'doctor':
        return UserRole.doctor;
      case 'patient':
        return UserRole.patient;
      case 'receptionist':
        return UserRole.receptionist;
      default:
        return UserRole.noRole;
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        LoginPage.route(null),
        (route) => false,
      );
    }
  }

  void _onProfilePressed() {
    // TODO: Implement Profile
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unimplemented.')),
    );
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
            MenuItemsGridView(currentMenuItems: currentMenuItems),
          ],
        ),
      ),
    );
  }
}
