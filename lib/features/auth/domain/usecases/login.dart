import 'package:dartz/dartz.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/features/auth/domain/repository/auth_repository.dart';
import 'package:merema/features/auth/data/models/auth_req_params.dart';

class LoginUseCase implements UseCase<Either, LoginReqParams> {
  @override
  Future<Either> call(LoginReqParams? params) async {
    return sl<AuthRepository>().login(params!);
  }
}
