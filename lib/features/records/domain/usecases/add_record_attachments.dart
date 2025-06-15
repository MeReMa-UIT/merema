import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/usecases/usecase.dart';
import 'package:merema/features/auth/domain/repositories/auth_repository.dart';
import 'package:merema/features/records/domain/repositories/record_repository.dart';

class AddRecordAttachmentsUseCase implements UseCase<Either, (int, File)> {
  final AuthRepository authRepository;

  AddRecordAttachmentsUseCase({required this.authRepository});

  @override
  Future<Either> call((int, File) params) async {
    final token = await authRepository.getToken();

    if (token.isEmpty) {
      return Left(Error());
    }

    final (recordId, file) = params;

    return await sl<RecordRepository>().addRecordAttachments(
      recordId,
      file,
      token,
    );
  }
}
