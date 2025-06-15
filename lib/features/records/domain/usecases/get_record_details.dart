import 'package:dartz/dartz.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/features/auth/domain/repositories/auth_repository.dart';
import 'package:merema/features/records/domain/repositories/record_repository.dart';

class GetRecordDetailsUseCase implements UseCase<Either, int> {
  final AuthRepository authRepository;

  GetRecordDetailsUseCase({required this.authRepository});

  @override
  Future<Either> call(int recordId) async {
    final token = await authRepository.getToken();

    if (token.isEmpty) {
      return Left(Error());
    }

    return await sl<RecordRepository>().getRecordDetails(recordId, token);
  }
}
