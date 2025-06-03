import 'package:dartz/dartz.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/features/patients/domain/repositories/patient_repository.dart';
import 'package:merema/features/auth/domain/repositories/auth_repository.dart';
import 'package:merema/core/layers/data/model/account_req_params.dart';
import 'package:merema/features/patients/data/models/patient_register_req_params.dart';

class RegisterPatientUseCase
    implements
        UseCase<Either, Tuple2<AccountReqParams, PatientRegisterReqParams>> {
  final AuthRepository authRepository;

  RegisterPatientUseCase({required this.authRepository});

  @override
  Future<Either> call(
      Tuple2<AccountReqParams, PatientRegisterReqParams> params) async {
    final token = await authRepository.getToken();
    if (token.isEmpty) {
      return Left(Error());
    }
    final accountParams = params.value1;
    final patientParams = params.value2;
    return await sl<PatientRepository>()
        .registerPatient(accountParams, patientParams, token);
  }
}
