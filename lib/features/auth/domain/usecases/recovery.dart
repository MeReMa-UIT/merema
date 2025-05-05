import 'package:dartz/dartz.dart';
import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/core/utils/service_locator.dart';
import 'package:merema/features/auth/domain/repository/auth_repository.dart';
import 'package:merema/features/data/models/auth_req_params.dart';

class RecoveryUseCase implements UseCase<Either, RecoveryReqParams> {
  @override
  Future<Either> call(RecoveryReqParams? params) async {
    return sl<AuthRepository>().recovery(params!);
  }
}

class RecoveryConfirmUseCase
    implements UseCase<Either, RecoveryConfirmReqParams> {
  @override
  Future<Either> call(RecoveryConfirmReqParams? params) async {
    return sl<AuthRepository>().recoveryConfirm(params!);
  }
}

class RecoveryResetUseCase implements UseCase<Either, RecoveryResetReqParams> {
  @override
  Future<Either> call(RecoveryResetReqParams? params) async {
    return sl<AuthRepository>().recoveryReset(params!);
  }
}
