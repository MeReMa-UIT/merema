import 'package:dartz/dartz.dart';
import 'package:merema/features/records/domain/entities/record.dart';
import 'package:merema/features/records/domain/entities/record_detail.dart';
import 'package:merema/features/records/domain/entities/record_type.dart';
import 'package:merema/features/records/domain/entities/diagnosis.dart';

abstract class RecordRepository {
  Future<Either<Error, List<Record>>> getRecords(String token);
  Future<Either<Error, int>> addRecord(
    int patientId,
    Map<String, dynamic> recordDetail,
    String typeId,
    String token,
  );
  Future<Either<Error, RecordDetail>> getRecordDetails(
      int recordId, String token);
  Future<Either<Error, List<RecordType>>> getRecordTypes(String token);
  Future<Either<Error, Map<String, dynamic>>> getRecordTypeTemplate(
    String typeId,
    String token,
  );
  Future<Either<Error, void>> updateRecord(
    int recordId,
    Map<String, dynamic> newRecordDetail,
    String token,
  );
  Future<Either<Error, List<Diagnosis>>> getDiagnoses(String token);
  Future<Either<Error, Diagnosis>> getDiagnosisByCode(
      String icdCode, String token);
}
