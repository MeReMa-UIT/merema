import 'package:dartz/dartz.dart';
import 'package:merema/features/statistics/domain/entities/statistic_record.dart';
import 'package:merema/features/statistics/domain/entities/statistic_record_by_diagnosis.dart';
import 'package:merema/features/statistics/domain/entities/statistic_record_by_doctor.dart';
import 'package:merema/features/statistics/domain/entities/statistic_request.dart';

abstract class StatisticRepository {
  Future<Either<Error, List<StatisticRecord>>> getRecordsStatistics(
    StatisticRequest request,
    String token,
  );

  Future<Either<Error, List<StatisticRecordByDiagnosis>>>
      getRecordsStatisticsByDiagnosis(
    StatisticRequest request,
    String token,
  );

  Future<Either<Error, List<StatisticRecordByDoctor>>>
      getRecordsStatisticsByDoctor(
    StatisticRequest request,
    String token,
  );
}
