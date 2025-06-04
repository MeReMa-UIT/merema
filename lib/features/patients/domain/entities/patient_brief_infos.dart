import 'package:equatable/equatable.dart';

class PatientBriefInfos extends Equatable {
  final String dateOfBirth;
  final String fullName;
  final String gender;
  final int patientId;

  const PatientBriefInfos({
    required this.dateOfBirth,
    required this.fullName,
    required this.gender,
    required this.patientId,
  });

  @override
  List<Object?> get props => [dateOfBirth, fullName, gender, patientId];
}

class PatientsBriefInfos extends Equatable {
  final List<PatientBriefInfos> patients;

  const PatientsBriefInfos({
    required this.patients,
  });

  @override
  List<Object?> get props => [patients];
}
