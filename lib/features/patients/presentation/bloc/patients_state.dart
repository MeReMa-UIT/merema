import 'package:merema/core/layers/domain/entities/user_role.dart';
import 'package:merema/features/patients/domain/entities/patient_brief_infos.dart';

abstract class PatientsState {}

class PatientsInitial extends PatientsState {}

class PatientsLoading extends PatientsState {}

class PatientsLoaded extends PatientsState {
  final List<PatientBriefInfos> allPatients;
  final List<PatientBriefInfos> filteredPatients;
  final UserRole userRole;

  PatientsLoaded({
    required this.allPatients,
    required this.filteredPatients,
    required this.userRole,
  });

  PatientsLoaded copyWith({
    List<PatientBriefInfos>? allPatients,
    List<PatientBriefInfos>? filteredPatients,
    UserRole? userRole,
  }) {
    return PatientsLoaded(
      allPatients: allPatients ?? this.allPatients,
      filteredPatients: filteredPatients ?? this.filteredPatients,
      userRole: userRole ?? this.userRole,
    );
  }
}

class PatientsError extends PatientsState {
  final String message;
  PatientsError(this.message);
}
