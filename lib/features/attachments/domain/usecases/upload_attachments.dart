import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/features/auth/domain/repositories/auth_repository.dart';
import 'package:merema/features/attachments/domain/repositories/attachment_repository.dart';

class UploadAttachmentsUseCase
    implements UseCase<Either<Error, dynamic>, (int, File)> {
  final AuthRepository authRepository;

  UploadAttachmentsUseCase({required this.authRepository});

  @override
  Future<Either<Error, dynamic>> call((int, File) params) async {
    final token = await authRepository.getToken();

    if (token.isEmpty) {
      return Left(Error());
    }

    final (recordId, file) = params;

    return await sl<AttachmentRepository>().uploadRecordAttachments(
      recordId,
      file,
      token,
    );
  }
}
