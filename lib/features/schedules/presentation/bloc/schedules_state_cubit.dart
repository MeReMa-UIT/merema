import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/schedules/domain/usecases/get_schedules.dart';
import 'package:merema/features/schedules/presentation/bloc/schedules_state.dart';

class SchedulesCubit extends Cubit<SchedulesState> {
  SchedulesCubit() : super(SchedulesInitial());

  Future<void> getSchedules({
    List<int>? types,
    List<int>? statuses,
  }) async {
    emit(SchedulesLoading());

    final typesToQuery = types ?? [1, 2];
    final statusesToQuery = statuses ?? [1, 2, 3];

    final result =
        await sl<GetSchedulesUseCase>().call((typesToQuery, statusesToQuery));

    result.fold(
      (error) => emit(SchedulesError(error.toString())),
      (schedules) {
        emit(SchedulesLoaded(schedules: schedules));
      },
    );
  }
}
