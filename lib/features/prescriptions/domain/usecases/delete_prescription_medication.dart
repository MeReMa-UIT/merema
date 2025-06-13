import 'package:dartz/dartz.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/features/auth/domain/repositories/auth_repository.dart';
import 'package:merema/features/prescriptions/domain/repositories/prescription_repository.dart';

class DeletePrescriptionMedicationUseCase
    implements UseCase<Either, (int, int)> {
  final AuthRepository authRepository;

  DeletePrescriptionMedicationUseCase({required this.authRepository});

  @override
  Future<Either> call((int, int) params) async {
    final token = await authRepository.getToken();
    if (token.isEmpty) {
      return Left(Error());
    }
    final (prescriptionId, medId) = params;
    return await sl<PrescriptionRepository>().deletePrescriptionMedication(
      prescriptionId,
      medId,
      token,
    );
  }
}
