import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/staffs/domain/usecases/get_staffs_list.dart';
import 'package:merema/features/staffs/presentation/bloc/staffs_state.dart';

class StaffsCubit extends Cubit<StaffsState> {
  StaffsCubit() : super(StaffsInitial());

  Future<void> getStaffs() async {
    emit(StaffsLoading());

    final result = await sl<GetStaffsListUseCase>().call(null);

    result.fold(
      (error) => emit(StaffsError(error.toString())),
      (staffBriefInfos) {
        final staffs = staffBriefInfos.staffs;
        emit(StaffsLoaded(
          allStaffs: staffs,
          filteredStaffs: List.from(staffs),
        ));
      },
    );
  }

  void searchStaffs({
    String searchQuery = '',
  }) {
    final currentState = state;
    if (currentState is StaffsLoaded) {
      final filteredStaffs = currentState.allStaffs.where((staff) {
        return searchQuery.isEmpty ||
            staff.fullName.toLowerCase().contains(searchQuery.toLowerCase()) ||
            staff.dateOfBirth
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            staff.department
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            staff.gender.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();

      emit(currentState.copyWith(filteredStaffs: filteredStaffs));
    }
  }

  void clearSearch() {
    final currentState = state;
    if (currentState is StaffsLoaded) {
      emit(currentState.copyWith(
        filteredStaffs: List.from(currentState.allStaffs),
      ));
    }
  }
}
