import 'package:merema/core/layers/domain/entities/user_role.dart';

abstract class AuthState {}

class AuthInitialState extends AuthState {}

class AuthenticatedState extends AuthState {
  final UserRole userRole;

  AuthenticatedState({required this.userRole});
}

class UnauthenticatedState extends AuthState {}
