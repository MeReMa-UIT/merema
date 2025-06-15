import 'package:dartz/dartz.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/features/auth/domain/repositories/auth_repository.dart';
import 'package:merema/features/records/domain/repositories/record_repository.dart';

class GetRecordAttachmentsUseCase implements UseCase<Either, int> {
  final AuthRepository authRepository;

  GetRecordAttachmentsUseCase({required this.authRepository});

  @override
  Future<Either> call(int recordId) async {
    final token = await authRepository.getToken();

    if (token.isEmpty) {
      return Left(Error());
    }

    return await sl<RecordRepository>().getRecordAttachments(recordId, token);
  }
}
