import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:merema/core/network/dio_client.dart';
import 'package:merema/core/utils/error_handler.dart';
import 'package:merema/core/services/service_locator.dart';

abstract class AttachmentApiService {
  Future<Either<ApiError, File>> getRecordAttachmentsZip(
      int recordId, String token);
  Future<Either<ApiError, dynamic>> uploadRecordAttachments(
      int recordId, File file, String token);
  Future<Either<ApiError, dynamic>> deleteRecordAttachments(
      int recordId, String attachmentFileName, String token);
}

class AttachmentApiServiceImpl implements AttachmentApiService {
  @override
  Future<Either<ApiError, File>> getRecordAttachmentsZip(
    int recordId,
    String token,
  ) async {
    try {
      final response = await sl<DioClient>().download(
        '/records/$recordId/attachments',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'record_${recordId}_attachments_${DateTime.now().millisecondsSinceEpoch}.zip';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      await file.writeAsBytes(response.data);

      return Right(file);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<ApiError, dynamic>> uploadRecordAttachments(
    int recordId,
    File file,
    String token,
  ) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        "attachments":
            await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final headers = <String, dynamic>{
        'Authorization': 'Bearer $token',
      };

      final response = await sl<DioClient>().post(
        '/records/$recordId/attachments',
        data: formData,
        headers: headers,
      );

      return Right(response.data);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<ApiError, dynamic>> deleteRecordAttachments(
    int recordId,
    String attachmentFileName,
    String token,
  ) async {
    try {
      final response = await sl<DioClient>().delete(
        '/records/$recordId/attachments',
        headers: {
          'Authorization': 'Bearer $token',
        },
        data: {
          'attachment_file_name': attachmentFileName,
        },
      );

      return Right(response.data);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }
}
