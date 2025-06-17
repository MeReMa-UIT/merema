import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:merema/features/attachments/domain/entities/attachment.dart';

abstract class AttachmentRepository {
  Future<Either<Error, File>> getRecordAttachmentsZip(
      int recordId, String token);
  Future<Either<Error, dynamic>> uploadRecordAttachments(
      int recordId, File file, String token);
  Future<Either<Error, dynamic>> deleteRecordAttachments(
      int recordId, String attachmentFileName, String token);
  Future<Either<Error, List<Attachment>>> extractAndOrganizeAttachments(
      File zipFile, int recordId);
}
