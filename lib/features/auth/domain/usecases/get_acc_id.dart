import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/features/auth/domain/repositories/auth_repository.dart';

class GetAccIdUseCase implements UseCase<int, dynamic> {
  @override
  Future<int> call(dynamic params) async {
    return await sl<AuthRepository>().getUserAccId();
  }
}
