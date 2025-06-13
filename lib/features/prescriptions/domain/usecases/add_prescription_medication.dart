import 'package:dartz/dartz.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/features/auth/domain/repositories/auth_repository.dart';
import 'package:merema/features/prescriptions/domain/repositories/prescription_repository.dart';

class AddPrescriptionMedicationUseCase
    implements UseCase<Either, (int, List<Map<String, dynamic>>)> {
  final AuthRepository authRepository;

  AddPrescriptionMedicationUseCase({required this.authRepository});

  @override
  Future<Either> call((int, List<Map<String, dynamic>>) params) async {
    final token = await authRepository.getToken();
    if (token.isEmpty) {
      return Left(Error());
    }
    final (prescriptionId, medData) = params;
    return await sl<PrescriptionRepository>().addPrescriptionMedication(
      prescriptionId,
      medData,
      token,
    );
  }
}
