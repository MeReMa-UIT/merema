import 'package:dartz/dartz.dart';
import '../entities/schedule.dart';

abstract class ScheduleRepository {
  Future<Either<Error, List<Schedule>>> getSchedules(
    String token, {
    List<int>? types,
    List<int>? statuses,
  });

  Future<Either<Error, dynamic>> bookSchedule(
    String token, {
    required String examinationDate,
    required int type,
  });

  Future<Either<Error, dynamic>> updateScheduleStatus(
    String token, {
    required int scheduleId,
    required int newStatus,
    required String receptionTime,
  });
}
