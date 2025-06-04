// TODO: Strip date and time format

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/theme/theme.dart';
import 'package:merema/features/auth/presentation/bloc/auth_bloc/auth_state.dart';
import 'package:merema/features/auth/presentation/bloc/auth_bloc/auth_state_cubit.dart';
import 'package:merema/features/auth/presentation/pages/login_page.dart';
import 'package:merema/features/home/presentation/pages/home_page.dart';
import 'package:merema/core/services/navigation_service.dart';
import 'dart:io';
import 'package:window_size/window_size.dart';

final NavigationService navigationService = NavigationService();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('MeReMa');
    setWindowMinSize(const Size(600, 800));
    setWindowMaxSize(Size.infinite);
  }

  setupServiceLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthStateCubit()..appStarted(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MeReMa',
        theme: AppTheme.lightThemeMode,
        navigatorKey: navigationService.navigatorKey,
        home: BlocBuilder<AuthStateCubit, AuthState>(
          builder: (context, state) {
            if (state is AuthenticatedState) {
              return const HomePage();
            } else if (state is UnauthenticatedState) {
              return const LoginPage();
            }
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        ),
      ),
    );
  }
}
