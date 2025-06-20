import 'package:dartz/dartz.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/features/auth/domain/repositories/auth_repository.dart';
import 'package:merema/features/prescriptions/domain/repositories/prescription_repository.dart';

class GetMedicationByIdUseCase implements UseCase<Either, int> {
  final AuthRepository authRepository;

  GetMedicationByIdUseCase({required this.authRepository});

  @override
  Future<Either> call(int medicationId) async {
    final token = await authRepository.getToken();

    if (token.isEmpty) {
      return Left(Error());
    }

    return await sl<PrescriptionRepository>()
        .getMedicationById(medicationId, token);
  }
}
