abstract class AuthState {}

class AuthInitialState extends AuthState {}

class AuthenticatedState extends AuthState {}

class UnauthenticatedState extends AuthState {}
