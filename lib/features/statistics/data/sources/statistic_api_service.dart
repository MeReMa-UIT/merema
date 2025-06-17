import 'package:dartz/dartz.dart';
import 'package:merema/core/network/dio_client.dart';
import 'package:merema/core/utils/error_handler.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/statistics/data/models/statistic_record_model.dart';
import 'package:merema/features/statistics/data/models/statistic_record_by_diagnosis_model.dart';
import 'package:merema/features/statistics/data/models/statistic_record_by_doctor_model.dart';
import 'package:merema/features/statistics/domain/entities/statistic_request.dart';

abstract class StatisticApiService {
  Future<Either<ApiError, List<StatisticRecordModel>>> getRecordsStatistics(
    StatisticRequest request,
    String token,
  );

  Future<Either<ApiError, List<StatisticRecordByDiagnosisModel>>>
      getRecordsStatisticsByDiagnosis(
    StatisticRequest request,
    String token,
  );

  Future<Either<ApiError, List<StatisticRecordByDoctorModel>>>
      getRecordsStatisticsByDoctor(
    StatisticRequest request,
    String token,
  );
}

class StatisticApiServiceImpl implements StatisticApiService {
  @override
  Future<Either<ApiError, List<StatisticRecordModel>>> getRecordsStatistics(
    StatisticRequest request,
    String token,
  ) async {
    try {
      final response = await sl<DioClient>().post(
        '/statistic/records',
        data: {
          'time_unit': request.timeUnit,
          'timestamp': request.timestamp,
        },
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final statisticsList = (response.data as List<dynamic>)
          .map((json) => StatisticRecordModel.fromJson(json))
          .toList();

      return Right(statisticsList);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<ApiError, List<StatisticRecordByDiagnosisModel>>>
      getRecordsStatisticsByDiagnosis(
    StatisticRequest request,
    String token,
  ) async {
    try {
      final response = await sl<DioClient>().post(
        '/statistic/records/diagnosis',
        data: {
          'time_unit': request.timeUnit,
          'timestamp': request.timestamp,
        },
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final statisticsList = (response.data as List<dynamic>)
          .map((json) => StatisticRecordByDiagnosisModel.fromJson(json))
          .toList();

      return Right(statisticsList);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<ApiError, List<StatisticRecordByDoctorModel>>>
      getRecordsStatisticsByDoctor(
    StatisticRequest request,
    String token,
  ) async {
    try {
      final response = await sl<DioClient>().post(
        '/statistic/records/doctor',
        data: {
          'time_unit': request.timeUnit,
          'timestamp': request.timestamp,
        },
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final statisticsList = (response.data as List<dynamic>)
          .map((json) => StatisticRecordByDoctorModel.fromJson(json))
          .toList();

      return Right(statisticsList);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }
}
