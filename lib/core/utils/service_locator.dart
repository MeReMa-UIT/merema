import 'package:get_it/get_it.dart';
import 'package:merema/core/network/dio_client.dart';
import 'package:merema/features/auth/data/source/auth_local_service.dart';
import 'package:merema/features/auth/domain/repository/auth_repository.dart';
import 'package:merema/features/auth/domain/usecases/is_logged_in.dart';
import 'package:merema/features/auth/domain/usecases/login.dart';
import 'package:merema/features/auth/domain/usecases/recovery.dart';
import 'package:merema/features/auth/data/repository/auth_repository_impl.dart';
import 'package:merema/features/auth/data/source/auth_api_service.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  sl.registerSingleton<DioClient>(DioClient());

  // Services
  sl.registerSingleton<AuthApiService>(AuthApiServiceImpl());
  sl.registerSingleton<AuthLocalService>(AuthLocalServiceImpl());

  // Repositories
  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl());

  // Use cases
  sl.registerSingleton<LoginUseCase>(LoginUseCase());
  sl.registerSingleton<RecoveryUseCase>(RecoveryUseCase());
  sl.registerSingleton<RecoveryConfirmUseCase>(RecoveryConfirmUseCase());
  sl.registerSingleton<RecoveryResetUseCase>(RecoveryResetUseCase());
  sl.registerSingleton<IsLoggedInUseCase>(IsLoggedInUseCase());
}
