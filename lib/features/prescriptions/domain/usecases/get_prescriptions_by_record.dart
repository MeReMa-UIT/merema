import 'package:dartz/dartz.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/features/auth/domain/repositories/auth_repository.dart';
import 'package:merema/features/prescriptions/domain/repositories/prescription_repository.dart';

class GetPrescriptionsByRecordUseCase implements UseCase<Either, int> {
  final AuthRepository authRepository;

  GetPrescriptionsByRecordUseCase({required this.authRepository});

  @override
  Future<Either> call(int recordId) async {
    final token = await authRepository.getToken();

    if (token.isEmpty) {
      return Left(Error());
    }

    return await sl<PrescriptionRepository>()
        .getPrescriptionsByRecordId(recordId, token);
  }
}
