import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/profile/domain/usecases/get_user_profile.dart';
import 'package:merema/features/profile/presentation/bloc/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  Future<void> getProfile() async {
    emit(ProfileLoading());

    final result = await sl<GetUserProfileUseCase>().call(null);

    result.fold(
      (error) => emit(ProfileError(error.toString())),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }
}
