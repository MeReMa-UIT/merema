// TODO: add userRole

abstract class AuthState {}

class AuthInitialState extends AuthState {}

class AuthenticatedState extends AuthState {
  //final String userRole;

  //AuthenticatedState({required this.userRole});
}

class UnauthenticatedState extends AuthState {}
