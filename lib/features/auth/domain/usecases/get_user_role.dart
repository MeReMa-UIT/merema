import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/features/auth/domain/repository/auth_repository.dart';

class GetUserRoleUseCase implements UseCase<String, dynamic> {
  @override
  Future<String> call(dynamic params) async {
    return await sl<AuthRepository>().getUserRole();
  }
}
