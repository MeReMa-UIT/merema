import 'package:dartz/dartz.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/utils/error_handler.dart';
import 'package:merema/features/statistics/data/sources/statistic_api_service.dart';
import 'package:merema/features/statistics/domain/entities/statistic_record.dart';
import 'package:merema/features/statistics/domain/entities/statistic_record_by_diagnosis.dart';
import 'package:merema/features/statistics/domain/entities/statistic_record_by_doctor.dart';
import 'package:merema/features/statistics/domain/entities/statistic_request.dart';
import 'package:merema/features/statistics/domain/repositories/statistic_repository.dart';

class StatisticRepositoryImpl implements StatisticRepository {
  @override
  Future<Either<Error, List<StatisticRecord>>> getRecordsStatistics(
    StatisticRequest request,
    String token,
  ) async {
    try {
      final result =
          await sl<StatisticApiService>().getRecordsStatistics(request, token);
      return result.fold(
        (error) => Left(error),
        (statistics) => Right(statistics.cast<StatisticRecord>()),
      );
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<Error, List<StatisticRecordByDiagnosis>>>
      getRecordsStatisticsByDiagnosis(
    StatisticRequest request,
    String token,
  ) async {
    try {
      final result = await sl<StatisticApiService>()
          .getRecordsStatisticsByDiagnosis(request, token);
      return result.fold(
        (error) => Left(error),
        (statistics) => Right(statistics.cast<StatisticRecordByDiagnosis>()),
      );
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<Error, List<StatisticRecordByDoctor>>>
      getRecordsStatisticsByDoctor(
    StatisticRequest request,
    String token,
  ) async {
    try {
      final result = await sl<StatisticApiService>()
          .getRecordsStatisticsByDoctor(request, token);
      return result.fold(
        (error) => Left(error),
        (statistics) => Right(statistics.cast<StatisticRecordByDoctor>()),
      );
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }
}
