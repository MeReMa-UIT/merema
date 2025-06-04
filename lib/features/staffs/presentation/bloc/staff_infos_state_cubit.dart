import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/staffs/domain/usecases/get_staff_infos.dart';
import 'package:merema/features/staffs/presentation/bloc/staff_infos_state.dart';

class StaffInfosCubit extends Cubit<StaffInfosState> {
  StaffInfosCubit() : super(StaffInfosInitial());

  Future<void> getInfos(int staffId) async {
    emit(StaffInfosLoading());

    final result = await sl<GetStaffInfosUseCase>().call(staffId);

    result.fold(
      (error) => emit(StaffInfosError(error.toString())),
      (staffInfo) {
        emit(StaffInfosLoaded(staffInfo: staffInfo));
      },
    );
  }
}
