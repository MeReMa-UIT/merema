import 'package:merema/core/domain/entities/user_role.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/features/auth/domain/repository/auth_repository.dart';

class GetUserRoleUseCase implements UseCase<UserRole, dynamic> {
  @override
  Future<UserRole> call(dynamic params) async {
    try {
      final roleString = await sl<AuthRepository>().getUserRole();
      return UserRoleExtension.fromString(roleString);
    } catch (e) {
      return UserRole.noRole;
    }
  }
}
