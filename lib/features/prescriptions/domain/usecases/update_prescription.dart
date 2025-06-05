import 'package:dartz/dartz.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/features/auth/domain/repositories/auth_repository.dart';
import 'package:merema/features/prescriptions/domain/repositories/prescription_repository.dart';

class UpdatePrescriptionUseCase
    implements UseCase<Either, (int, Map<String, dynamic>)> {
  final AuthRepository authRepository;

  UpdatePrescriptionUseCase({required this.authRepository});

  @override
  Future<Either> call((int, Map<String, dynamic>) params) async {
    final token = await authRepository.getToken();

    if (token.isEmpty) {
      return Left(Error());
    }

    final (prescriptionId, updates) = params;

    return await sl<PrescriptionRepository>().updatePrescription(
      prescriptionId,
      updates,
      token,
    );
  }
}
