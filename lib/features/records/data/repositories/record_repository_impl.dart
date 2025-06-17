import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/utils/error_handler.dart';
import 'package:merema/features/records/data/sources/record_api_service.dart';
import 'package:merema/features/records/domain/entities/record.dart';
import 'package:merema/features/records/domain/entities/record_detail.dart';
import 'package:merema/features/records/domain/entities/record_type.dart';
import 'package:merema/features/records/domain/entities/diagnosis.dart';
import 'package:merema/features/records/domain/repositories/record_repository.dart';

class RecordRepositoryImpl implements RecordRepository {
  @override
  Future<Either<Error, List<Record>>> getRecords(String token) async {
    try {
      final result = await sl<RecordApiService>().getRecords(token);
      return result.fold(
        (error) => Left(error),
        (records) => Right(records.cast<Record>()),
      );
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<Error, int>> addRecord(
    int patientId,
    Map<String, dynamic> recordDetail,
    String typeId,
    String token,
  ) async {
    try {
      final result = await sl<RecordApiService>().addRecord(
        patientId,
        recordDetail,
        typeId,
        token,
      );
      return result.fold(
        (error) => Left(error),
        (recordId) => Right(recordId),
      );
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<Error, RecordDetail>> getRecordDetails(
    int recordId,
    String token,
  ) async {
    try {
      final result = await sl<RecordApiService>().getRecordDetails(
        recordId,
        token,
      );
      return result.fold(
        (error) => Left(error),
        (recordDetail) => Right(recordDetail),
      );
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<Error, List<RecordType>>> getRecordTypes(String token) async {
    try {
      final result = await sl<RecordApiService>().getRecordTypes(token);
      return result.fold(
        (error) => Left(error),
        (recordTypes) => Right(recordTypes.cast<RecordType>()),
      );
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<Error, Map<String, dynamic>>> getRecordTypeTemplate(
    String typeId,
    String token,
  ) async {
    try {
      final result = await sl<RecordApiService>().getRecordTypeTemplate(
        typeId,
        token,
      );
      return result.fold(
        (error) => Left(error),
        (template) => Right(template),
      );
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<Error, void>> updateRecord(
    int recordId,
    Map<String, dynamic> newRecordDetail,
    String token,
  ) async {
    try {
      final result = await sl<RecordApiService>().updateRecord(
        recordId,
        newRecordDetail,
        token,
      );
      return result.fold(
        (error) => Left(error),
        (_) => const Right(null),
      );
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<Error, File>> getRecordAttachments(
    int recordId,
    String token,
  ) async {
    try {
      final result = await sl<RecordApiService>().getRecordAttachments(
        recordId,
        token,
      );
      return result.fold(
        (error) => Left(error),
        (file) => Right(file),
      );
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<Error, dynamic>> addRecordAttachments(
    int recordId,
    File file,
    String token,
  ) async {
    try {
      final result = await sl<RecordApiService>().addRecordAttachments(
        recordId,
        file,
        token,
      );
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
    String token,
  ) async {
    try {
      final result = await sl<RecordApiService>().deleteRecordAttachments(
        recordId,
        token,
      );
      return result.fold(
        (error) => Left(error),
        (response) => Right(response),
      );
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<Error, List<Diagnosis>>> getDiagnoses(String token) async {
    try {
      final result = await sl<RecordApiService>().getDiagnoses(token);
      return result.fold(
        (error) => Left(error),
        (diagnoses) => Right(diagnoses.cast<Diagnosis>()),
      );
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<Error, Diagnosis>> getDiagnosisByCode(
    String icdCode,
    String token,
  ) async {
    try {
      final result = await sl<RecordApiService>().getDiagnosisByCode(
        icdCode,
        token,
      );
      return result.fold(
        (error) => Left(error),
        (diagnosis) => Right(diagnosis),
      );
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }
}
