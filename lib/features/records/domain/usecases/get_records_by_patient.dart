import 'package:dartz/dartz.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/features/auth/domain/repositories/auth_repository.dart';
import 'package:merema/features/records/domain/repositories/record_repository.dart';

class GetRecordsByPatientUseCase implements UseCase<Either, int> {
  final AuthRepository authRepository;

  GetRecordsByPatientUseCase({required this.authRepository});

  @override
  Future<Either> call(int patientId) async {
    final token = await authRepository.getToken();

    if (token.isEmpty) {
      return Left(Error());
    }

    // Get all records and filter by patient ID
    final result = await sl<RecordRepository>().getRecords(token);

    return result.fold(
      (error) => Left(error),
      (records) {
        final patientRecords =
            records.where((record) => record.patientId == patientId).toList();
        return Right(patientRecords);
      },
    );
  }
}
