import 'package:get_it/get_it.dart';
import 'package:merema/core/network/dio_client.dart';
import 'package:merema/features/auth/data/sources/auth_local_service.dart';
import 'package:merema/features/auth/domain/repositories/auth_repository.dart';
import 'package:merema/features/auth/domain/usecases/get_token.dart';
import 'package:merema/features/auth/domain/usecases/get_user_role.dart';
import 'package:merema/features/auth/domain/usecases/is_logged_in.dart';
import 'package:merema/features/auth/domain/usecases/login.dart';
import 'package:merema/features/auth/domain/usecases/logout.dart';
import 'package:merema/features/auth/domain/usecases/recovery.dart';
import 'package:merema/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:merema/features/auth/data/sources/auth_api_service.dart';
import 'package:merema/features/patients/data/repositories/patient_repository_impl.dart';
import 'package:merema/features/patients/data/sources/patient_api_service.dart';
import 'package:merema/features/patients/domain/repositories/patient_repository.dart';
import 'package:merema/features/patients/domain/usecases/get_patient_infos.dart';
import 'package:merema/features/patients/domain/usecases/get_patients_list.dart';
import 'package:merema/features/patients/domain/usecases/register_patient.dart';
import 'package:merema/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:merema/features/profile/data/sources/profile_api_service.dart';
import 'package:merema/features/profile/data/sources/profile_local_service.dart';
import 'package:merema/features/profile/domain/repositories/profile_repository.dart';
import 'package:merema/features/profile/domain/usecases/get_user_profile.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  sl.registerSingleton<DioClient>(DioClient());

  // Services
  sl.registerSingleton<AuthApiService>(AuthApiServiceImpl());
  sl.registerSingleton<AuthLocalService>(AuthLocalServiceImpl());

  sl.registerSingleton<ProfileApiService>(ProfileApiServiceImpl());
  sl.registerSingleton<ProfileLocalService>(ProfileLocalServiceImpl());

  sl.registerSingleton<PatientApiService>(PatientApiServiceImpl());

  // Repositories
  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl());

  sl.registerSingleton<ProfileRepository>(ProfileRepositoryImpl());

  sl.registerSingleton<PatientRepository>(PatientRepositoryImpl());

  // Use cases
  sl.registerSingleton<LoginUseCase>(LoginUseCase());
  sl.registerSingleton<RecoveryUseCase>(RecoveryUseCase());
  sl.registerSingleton<RecoveryConfirmUseCase>(RecoveryConfirmUseCase());
  sl.registerSingleton<RecoveryResetUseCase>(RecoveryResetUseCase());
  sl.registerSingleton<IsLoggedInUseCase>(IsLoggedInUseCase());
  sl.registerSingleton<GetTokenUseCase>(GetTokenUseCase());
  sl.registerSingleton<GetUserRoleUseCase>(GetUserRoleUseCase());
  sl.registerSingleton<LogoutUseCase>(LogoutUseCase());

  sl.registerSingleton<GetUserProfileUseCase>(
      GetUserProfileUseCase(authRepository: sl()));

  sl.registerSingleton<GetPatientsListUseCase>(
    GetPatientsListUseCase(authRepository: sl()),
  );
  sl.registerSingleton<GetPatientInfosUseCase>(
    GetPatientInfosUseCase(authRepository: sl()),
  );
  sl.registerSingleton<RegisterPatientUseCase>(
    RegisterPatientUseCase(authRepository: sl()),
  );
}
