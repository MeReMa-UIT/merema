import 'package:flutter/material.dart';
import 'package:merema/core/theme/theme.dart';
import 'package:merema/features/auth/presentation/pages/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MeReMa',
      theme: AppTheme.lightThemeMode,
      home: const LoginPage(),
    );
  }
}
