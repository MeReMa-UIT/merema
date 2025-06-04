import 'package:equatable/equatable.dart';

class PatientInfos extends Equatable {
  final String address;
  final String dateOfBirth;
  final String emergencyContactInfo;
  final String ethnicity;
  final String fullName;
  final String gender;
  final String healthInsuranceExpiredDate;
  final String healthInsuranceNumber;
  final String nationality;
  final int patientId;

  const PatientInfos({
    required this.address,
    required this.dateOfBirth,
    required this.emergencyContactInfo,
    required this.ethnicity,
    required this.fullName,
    required this.gender,
    required this.healthInsuranceExpiredDate,
    required this.healthInsuranceNumber,
    required this.nationality,
    required this.patientId,
  });

  @override
  List<Object?> get props => [
        address,
        dateOfBirth,
        emergencyContactInfo,
        ethnicity,
        fullName,
        gender,
        healthInsuranceExpiredDate,
        healthInsuranceNumber,
        nationality,
        patientId,
      ];
}
