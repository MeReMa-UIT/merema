import 'package:dartz/dartz.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/features/auth/domain/repositories/auth_repository.dart';
import 'package:merema/features/attachments/domain/repositories/attachment_repository.dart';

class DeleteAttachmentsUseCase
    implements UseCase<Either<Error, dynamic>, (int, String)> {
  final AuthRepository authRepository;

  DeleteAttachmentsUseCase({required this.authRepository});

  @override
  Future<Either<Error, dynamic>> call((int, String) params) async {
    final token = await authRepository.getToken();

    if (token.isEmpty) {
      return Left(Error());
    }

    final (recordId, fileName) = params;

    return await sl<AttachmentRepository>()
        .deleteRecordAttachments(recordId, fileName, token);
  }
}
