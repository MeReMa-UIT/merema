import 'package:dartz/dartz.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/features/patients/domain/repositories/patient_repository.dart';
import 'package:merema/features/auth/domain/repositories/auth_repository.dart';
import 'package:merema/features/patients/data/models/patient_req_params.dart';

class UpdatePatientUseCase
    implements UseCase<Either, Tuple2<PatientReqParams, int>> {
  final AuthRepository authRepository;

  UpdatePatientUseCase({required this.authRepository});

  @override
  Future<Either> call(Tuple2<PatientReqParams, int> params) async {
    final token = await authRepository.getToken();
    if (token.isEmpty) {
      return Left(Error());
    }
    final patientParams = params.value1;
    final patientId = params.value2;
    return await sl<PatientRepository>()
        .updatePatient(patientParams, patientId, token);
  }
}
