import 'package:merema/features/staffs/domain/entities/staff_infos.dart';

abstract class StaffsState {}

class StaffsInitial extends StaffsState {}

class StaffsLoading extends StaffsState {}

class StaffsLoaded extends StaffsState {
  final List<StaffInfos> allStaffs;
  final List<StaffInfos> filteredStaffs;

  StaffsLoaded({
    required this.allStaffs,
    required this.filteredStaffs,
  });

  StaffsLoaded copyWith({
    List<StaffInfos>? allStaffs,
    List<StaffInfos>? filteredStaffs,
  }) {
    return StaffsLoaded(
      allStaffs: allStaffs ?? this.allStaffs,
      filteredStaffs: filteredStaffs ?? this.filteredStaffs,
    );
  }
}

class StaffsError extends StaffsState {
  final String message;
  StaffsError(this.message);
}
