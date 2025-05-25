import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/features/auth/domain/repositories/auth_repository.dart';

class GetTokenUseCase implements UseCase<String, dynamic> {
  @override
  Future<String> call(dynamic params) async {
    return await sl<AuthRepository>().getToken();
  }
}
