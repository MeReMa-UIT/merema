import 'dart:io';
import 'package:archive/archive.dart';
import 'package:dartz/dartz.dart';
import 'package:path_provider/path_provider.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/utils/error_handler.dart';
import 'package:merema/features/attachments/domain/entities/attachment.dart';
import 'package:merema/features/attachments/domain/repositories/attachment_repository.dart';
import 'package:merema/features/attachments/data/sources/attachment_api_service.dart';

class AttachmentRepositoryImpl implements AttachmentRepository {
  @override
  Future<Either<Error, File>> getRecordAttachmentsZip(
      int recordId, String token) async {
    try {
      final result = await sl<AttachmentApiService>()
          .getRecordAttachmentsZip(recordId, token);
      return result.fold(
        (error) => Left(error),
        (file) => Right(file),
      );
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<Error, dynamic>> uploadRecordAttachments(
    int recordId,
    File file,
    String token,
  ) async {
    try {
      final result = await sl<AttachmentApiService>()
          .uploadRecordAttachments(recordId, file, token);
      return result.fold(
        (error) => Left(error),
        (response) => Right(response),
      );
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<Error, dynamic>> deleteRecordAttachments(
    int recordId,
    String attachmentFileName,
    String token,
  ) async {
    try {
      final result = await sl<AttachmentApiService>()
          .deleteRecordAttachments(recordId, attachmentFileName, token);
      return result.fold(
        (error) => Left(error),
        (response) => Right(response),
      );
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<Error, List<Attachment>>> extractAndOrganizeAttachments(
    File zipFile,
    int recordId,
  ) async {
    try {
      final List<Attachment> attachments = [];

      final bytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      final documentsDir = await getApplicationDocumentsDirectory();
      final extractionDir =
          Directory('${documentsDir.path}/attachments/record_$recordId');

      if (!await extractionDir.exists()) {
        await extractionDir.create(recursive: true);
      }

      for (final file in archive) {
        if (file.isFile) {
          final fileName = file.name;

          AttachmentType type = _determineAttachmentType(fileName);

          final typeDir = Directory('${extractionDir.path}/${type.folderName}');
          if (!await typeDir.exists()) {
            await typeDir.create(recursive: true);
          }

          final typeSpecificPath =
              '${typeDir.path}/${fileName.split('/').last}';
          final outputFile = File(typeSpecificPath);
          await outputFile.writeAsBytes(file.content);

          final fileStats = await outputFile.stat();
          final attachment = Attachment(
            fileName: fileName.split('/').last,
            filePath: typeSpecificPath,
            type: type,
            sizeInBytes: fileStats.size,
            dateModified: fileStats.modified,
          );

          attachments.add(attachment);
        }
      }

      return Right(attachments);
    } catch (e) {
      return Left(
          ApiErrorHandler.handleError('Failed to extract attachments: $e'));
    }
  }

  AttachmentType _determineAttachmentType(String fileName) {
    final lowerFileName = fileName.toLowerCase();

    final fileNameOnly = fileName.split('/').last.toLowerCase();

    if (fileNameOnly.startsWith('xray_')) {
      return AttachmentType.xray;
    } else if (fileNameOnly.startsWith('ct_')) {
      return AttachmentType.ct;
    } else if (fileNameOnly.startsWith('ultrasound_')) {
      return AttachmentType.ultrasound;
    } else if (fileNameOnly.startsWith('test_')) {
      return AttachmentType.test;
    } else if (fileNameOnly.startsWith('other_')) {
      return AttachmentType.other;
    }

    if (lowerFileName.contains('xray/')) {
      return AttachmentType.xray;
    } else if (lowerFileName.contains('ct/')) {
      return AttachmentType.ct;
    } else if (lowerFileName.contains('ultrasound/')) {
      return AttachmentType.ultrasound;
    } else if (lowerFileName.contains('test/')) {
      return AttachmentType.test;
    } else if (lowerFileName.contains('other/')) {
      return AttachmentType.other;
    }

    return AttachmentType.other;
  }
}
