import 'dart:io';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:merema/core/network/dio_client.dart';
import 'package:merema/core/utils/error_handler.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/records/data/models/record_model.dart';
import 'package:merema/features/records/data/models/record_detail_model.dart';
import 'package:merema/features/records/data/models/record_type_model.dart';
import 'package:merema/features/records/data/models/diagnosis_model.dart';

abstract class RecordApiService {
  Future<Either<ApiError, List<RecordModel>>> getRecords(String token);
  Future<Either<ApiError, int>> addRecord(
    int patientId,
    Map<String, dynamic> recordDetail,
    String typeId,
    String token,
  );
  Future<Either<ApiError, RecordDetailModel>> getRecordDetails(
    int recordId,
    String token,
  );
  Future<Either<ApiError, List<RecordTypeModel>>> getRecordTypes(String token);
  Future<Either<ApiError, Map<String, dynamic>>> getRecordTypeTemplate(
    String typeId,
    String token,
  );
  Future<Either<ApiError, void>> updateRecord(
    int recordId,
    Map<String, dynamic> newRecordDetail,
    String token,
  );
  Future<Either<ApiError, File>> getRecordAttachments(
    int recordId,
    String token,
  );
  Future<Either<ApiError, dynamic>> addRecordAttachments(
    int recordId,
    File file,
    String token,
  );
  Future<Either<ApiError, dynamic>> deleteRecordAttachments(
    int recordId,
    String token,
  );
  Future<Either<ApiError, List<DiagnosisModel>>> getDiagnoses(String token);
  Future<Either<ApiError, DiagnosisModel>> getDiagnosisByCode(
    String icdCode,
    String token,
  );
}

class RecordApiServiceImpl implements RecordApiService {
  @override
  Future<Either<ApiError, List<RecordModel>>> getRecords(String token) async {
    try {
      final response = await sl<DioClient>().get(
        '/records',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final records = (response.data as List<dynamic>)
          .map((recordJson) => RecordModel.fromJson(recordJson))
          .toList();
      return Right(records);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<ApiError, int>> addRecord(
    int patientId,
    Map<String, dynamic> recordDetail,
    String typeId,
    String token,
  ) async {
    try {
      final response = await sl<DioClient>().post(
        '/records',
        data: jsonEncode({
          'patient_id': patientId,
          'record_detail': recordDetail,
          'type_id': typeId,
        }),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return Right(response.data['record_id']);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<ApiError, RecordDetailModel>> getRecordDetails(
    int recordId,
    String token,
  ) async {
    try {
      final response = await sl<DioClient>().get(
        '/records/$recordId',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final recordDetailModel = RecordDetailModel.fromJson(response.data);
      return Right(recordDetailModel);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<ApiError, List<RecordTypeModel>>> getRecordTypes(
      String token) async {
    try {
      final response = await sl<DioClient>().get(
        '/catalog/record-types',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final types = (response.data as List<dynamic>)
          .map((typeJson) => RecordTypeModel.fromJson(typeJson))
          .toList();
      return Right(types);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<ApiError, Map<String, dynamic>>> getRecordTypeTemplate(
    String typeId,
    String token,
  ) async {
    try {
      final response = await sl<DioClient>().get(
        '/catalog/record-types/$typeId/template',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return Right(response.data as Map<String, dynamic>);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<ApiError, void>> updateRecord(
    int recordId,
    Map<String, dynamic> newRecordDetail,
    String token,
  ) async {
    try {
      await sl<DioClient>().put(
        '/records/$recordId',
        data: jsonEncode({'new_record_detail': newRecordDetail}),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return const Right(null);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<ApiError, File>> getRecordAttachments(
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
  Future<Either<ApiError, dynamic>> addRecordAttachments(
    int recordId,
    File file,
    String token,
  ) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path, filename: fileName),
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
    String token,
  ) async {
    try {
      final response = await sl<DioClient>().delete(
        '/records/$recordId/attachments',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return Right(response.data);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<ApiError, List<DiagnosisModel>>> getDiagnoses(
      String token) async {
    try {
      final response = await sl<DioClient>().get(
        '/catalog/diagnoses',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final diagnoses = (response.data as List<dynamic>)
          .map((diagnosisJson) => DiagnosisModel.fromJson(diagnosisJson))
          .toList();
      return Right(diagnoses);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<ApiError, DiagnosisModel>> getDiagnosisByCode(
    String icdCode,
    String token,
  ) async {
    try {
      final response = await sl<DioClient>().get(
        '/catalog/diagnoses/$icdCode',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final diagnosisModel = DiagnosisModel.fromJson(response.data);
      return Right(diagnosisModel);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }
}
