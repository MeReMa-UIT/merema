import 'package:merema/features/staffs/domain/entities/staff_infos.dart';

abstract class StaffInfosState {}

class StaffInfosInitial extends StaffInfosState {}

class StaffInfosLoading extends StaffInfosState {}

class StaffInfosLoaded extends StaffInfosState {
  final StaffInfos staffInfo;

  StaffInfosLoaded({required this.staffInfo});
}

class StaffInfosError extends StaffInfosState {
  final String message;
  StaffInfosError(this.message);
}
