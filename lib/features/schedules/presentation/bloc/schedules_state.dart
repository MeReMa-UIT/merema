import 'package:merema/features/schedules/domain/entities/schedule.dart';

abstract class SchedulesState {}

class SchedulesInitial extends SchedulesState {}

class SchedulesLoading extends SchedulesState {}

class SchedulesLoaded extends SchedulesState {
  final List<Schedule> schedules;

  SchedulesLoaded({
    required this.schedules,
  });
}

class SchedulesError extends SchedulesState {
  final String message;
  SchedulesError(this.message);
}
