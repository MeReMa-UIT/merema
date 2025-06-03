import 'package:dartz/dartz.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/features/auth/domain/repositories/auth_repository.dart';
import 'package:merema/features/patients/domain/repositories/patient_repository.dart';

class GetPatientInfosUseCase implements UseCase<Either, int> {
  final AuthRepository authRepository;

  GetPatientInfosUseCase({required this.authRepository});

  @override
  Future<Either> call(int patientId) async {
    final token = await authRepository.getToken();

    if (token.isEmpty) {
      return Left(Error());
    }

    return await sl<PatientRepository>().getPatientInfos(patientId, token);
  }
}
