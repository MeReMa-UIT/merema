import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/features/auth/domain/repository/auth_repository.dart';

class LogoutUseCase implements UseCase<void, dynamic> {
  @override
  Future<void> call(dynamic params) async {
    return sl<AuthRepository>().logout();
  }
}