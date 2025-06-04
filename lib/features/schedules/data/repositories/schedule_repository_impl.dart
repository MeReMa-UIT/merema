import 'package:dartz/dartz.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/utils/error_handler.dart';
import 'package:merema/features/schedules/domain/repositories/schedule_repository.dart';
import 'package:merema/features/schedules/domain/entities/schedule.dart';
import '../sources/schedule_api_service.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  @override
  Future<Either<Error, List<Schedule>>> getSchedules(
    String token, {
    List<int>? types,
    List<int>? statuses,
  }) async {
    try {
      final result = await sl<ScheduleApiService>().fetchSchedules(
        token,
        types: types,
        statuses: statuses,
      );

      return result.fold(
        (error) => Left(error),
        (schedulesModel) => Right(schedulesModel.schedules),
      );
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<Error, dynamic>> bookSchedule(
    String token, {
    required String examinationDate,
    required int type,
  }) async {
    try {
      final result = await sl<ScheduleApiService>().bookSchedule(
        token,
        examinationDate: examinationDate,
        type: type,
      );

      return result.fold(
        (error) => Left(error),
        (data) => Right(data),
      );
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<Error, dynamic>> updateScheduleStatus(
    String token, {
    required int scheduleId,
    required int newStatus,
    required String receptionTime,
  }) async {
    try {
      final result = await sl<ScheduleApiService>().updateScheduleStatus(
        token,
        scheduleId: scheduleId,
        newStatus: newStatus,
        receptionTime: receptionTime,
      );

      return result.fold(
        (error) => Left(error),
        (data) => Right(data),
      );
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }
}
