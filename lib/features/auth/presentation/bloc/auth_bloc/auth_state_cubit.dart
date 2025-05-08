// TODO: add userRole

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/utils/service_locator.dart';
//import 'package:merema/features/auth/domain/usecases/get_user_role.dart';
import 'package:merema/features/auth/domain/usecases/is_logged_in.dart';
import 'package:merema/features/auth/presentation/bloc/auth_bloc/auth_state.dart';

class AuthStateCubit extends Cubit<AuthState> {
  AuthStateCubit() : super(AuthInitialState());

  Future<void> appStarted() async {
    var isLoggedIn = await sl<IsLoggedInUseCase>().call(null);
    //var userRole = await sl<GetUserRoleUseCase>().call(null);

    if (isLoggedIn) {
      emit(AuthenticatedState(
          //userRole: userRole,
          ));
    } else {
      emit(UnauthenticatedState());
    }
  }
}
