import 'package:dartz/dartz.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/features/auth/domain/repositories/auth_repository.dart';
import 'package:merema/features/records/domain/repositories/record_repository.dart';

class AddRecordUseCase
    implements UseCase<Either, (int, Map<String, dynamic>, String)> {
  final AuthRepository authRepository;

  AddRecordUseCase({required this.authRepository});

  @override
  Future<Either> call((int, Map<String, dynamic>, String) params) async {
    final token = await authRepository.getToken();

    if (token.isEmpty) {
      return Left(Error());
    }

    final (patientId, recordDetail, typeId) = params;

    return await sl<RecordRepository>().addRecord(
      patientId,
      recordDetail,
      typeId,
      token,
    );
  }
}
