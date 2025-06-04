import 'package:dartz/dartz.dart';
import 'package:merema/core/network/dio_client.dart';
import 'package:merema/core/utils/error_handler.dart';
import 'package:merema/core/services/service_locator.dart';
import '../models/schedule_model.dart';

abstract class ScheduleApiService {
  Future<Either<ApiError, SchedulesModel>> fetchSchedules(
    String token, {
    List<int>? types,
    List<int>? statuses,
  });

  Future<Either<ApiError, dynamic>> bookSchedule(
    String token, {
    required String examinationDate,
    required int type,
  });

  Future<Either<ApiError, dynamic>> updateScheduleStatus(
    String token, {
    required int scheduleId,
    required int newStatus,
    required String receptionTime,
  });
}

class ScheduleApiServiceImpl implements ScheduleApiService {
  @override
  Future<Either<ApiError, SchedulesModel>> fetchSchedules(
    String token, {
    List<int>? types,
    List<int>? statuses,
  }) async {
    try {
      Map<String, dynamic> queryParams = {};

      if (types != null && types.isNotEmpty) {
        queryParams['type[]'] = types;
      }

      if (statuses != null && statuses.isNotEmpty) {
        queryParams['status[]'] = statuses;
      }

      final response = await sl<DioClient>().get(
        '/schedules',
        queryParameters: queryParams,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final schedulesModel = SchedulesModel.fromJson(response.data);

      return Right(schedulesModel);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<ApiError, dynamic>> bookSchedule(
    String token, {
    required String examinationDate,
    required int type,
  }) async {
    try {
      final response = await sl<DioClient>().post(
        '/schedules/book',
        headers: {
          'Authorization': 'Bearer $token',
        },
        data: {
          'examination_date': examinationDate,
          'type': type,
        },
      );

      return Right(response.data);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<ApiError, dynamic>> updateScheduleStatus(
    String token, {
    required int scheduleId,
    required int newStatus,
    required String receptionTime,
  }) async {
    try {
      final response = await sl<DioClient>().put(
        '/schedules/update-status',
        headers: {
          'Authorization': 'Bearer $token',
        },
        data: {
          'schedule_id': scheduleId,
          'new_status': newStatus,
          'reception_time': receptionTime,
        },
      );

      return Right(response.data);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }
}
