import 'package:dartz/dartz.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/features/auth/domain/repositories/auth_repository.dart';
import 'package:merema/features/records/domain/repositories/record_repository.dart';

class UpdateRecordUseCase
    implements UseCase<Either, (int, Map<String, dynamic>)> {
  final AuthRepository authRepository;

  UpdateRecordUseCase({required this.authRepository});

  @override
  Future<Either> call((int, Map<String, dynamic>) params) async {
    final token = await authRepository.getToken();

    if (token.isEmpty) {
      return Left(Error());
    }

    final (recordId, newRecordDetail) = params;

    return await sl<RecordRepository>().updateRecord(
      recordId,
      newRecordDetail,
      token,
    );
  }
}
