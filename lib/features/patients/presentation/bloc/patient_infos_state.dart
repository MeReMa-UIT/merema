import 'package:merema/features/patients/domain/entities/patient_infos.dart';

abstract class PatientInfosState {}

class PatientInfosInitial extends PatientInfosState {}

class PatientInfosLoading extends PatientInfosState {}

class PatientInfosLoaded extends PatientInfosState {
  final PatientInfo patientInfo;

  PatientInfosLoaded({required this.patientInfo});
}

class PatientInfosError extends PatientInfosState {
  final String message;
  PatientInfosError(this.message);
}
