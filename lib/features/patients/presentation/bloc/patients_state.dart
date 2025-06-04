import 'package:merema/features/patients/domain/entities/patient_brief_infos.dart';

abstract class PatientsState {}

class PatientsInitial extends PatientsState {}

class PatientsLoading extends PatientsState {}

class PatientsLoaded extends PatientsState {
  final List<PatientBriefInfo> allPatients;
  final List<PatientBriefInfo> filteredPatients;

  PatientsLoaded({
    required this.allPatients,
    required this.filteredPatients,
  });

  PatientsLoaded copyWith({
    List<PatientBriefInfo>? allPatients,
    List<PatientBriefInfo>? filteredPatients,
  }) {
    return PatientsLoaded(
      allPatients: allPatients ?? this.allPatients,
      filteredPatients: filteredPatients ?? this.filteredPatients,
    );
  }
}

class PatientsError extends PatientsState {
  final String message;
  PatientsError(this.message);
}
