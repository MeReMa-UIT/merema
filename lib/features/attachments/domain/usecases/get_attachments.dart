import 'package:dartz/dartz.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/features/auth/domain/repositories/auth_repository.dart';
import 'package:merema/features/attachments/domain/entities/attachment.dart';
import 'package:merema/features/attachments/domain/repositories/attachment_repository.dart';

class GetAttachmentsUseCase
    implements UseCase<Either<Error, List<Attachment>>, int> {
  final AuthRepository authRepository;

  GetAttachmentsUseCase({required this.authRepository});

  @override
  Future<Either<Error, List<Attachment>>> call(int recordId) async {
    try {
      final token = await authRepository.getToken();

      if (token.isEmpty) {
        return Left(Error());
      }

      final zipResult = await sl<AttachmentRepository>()
          .getRecordAttachmentsZip(recordId, token);

      return zipResult.fold(
        (error) => Left(error),
        (zipFile) async {
          try {
            final attachmentsResult = await sl<AttachmentRepository>()
                .extractAndOrganizeAttachments(zipFile, recordId);

            return attachmentsResult.fold(
              (error) => Left(error),
              (attachments) => Right(attachments),
            );
          } catch (e) {
            return Left(Error());
          }
        },
      );
    } catch (e) {
      return Left(Error());
    }
  }
}
