import 'package:equatable/equatable.dart';

class PatientBriefInfo extends Equatable {
  final String dateOfBirth;
  final String fullName;
  final String gender;
  final int patientId;

  const PatientBriefInfo({
    required this.dateOfBirth,
    required this.fullName,
    required this.gender,
    required this.patientId,
  });

  @override
  List<Object?> get props => [dateOfBirth, fullName, gender, patientId];
}

class PatientBriefInfos extends Equatable {
  final List<PatientBriefInfo> patients;

  const PatientBriefInfos({
    required this.patients,
  });

  @override
  List<Object?> get props => [patients];
}
