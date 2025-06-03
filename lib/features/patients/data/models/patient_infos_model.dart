import 'package:merema/features/patients/domain/entities/patient_infos.dart';

class PatientInfosModel extends PatientInfo {
  const PatientInfosModel({
    required super.address,
    required super.dateOfBirth,
    required super.emergencyContactInfo,
    required super.ethnicity,
    required super.fullName,
    required super.gender,
    required super.healthInsuranceExpiredDate,
    required super.healthInsuranceNumber,
    required super.nationality,
    required super.patientId,
  });

  factory PatientInfosModel.fromJson(Map<String, dynamic> json) {
    return PatientInfosModel(
      address: json['address'],
      dateOfBirth: json['date_of_birth'].toString(),
      emergencyContactInfo: json['emergency_contact_info'],
      ethnicity: json['ethnicity'],
      fullName: json['full_name'],
      gender: json['gender'],
      healthInsuranceExpiredDate:
          json['health_insurance_expired_date'].toString(),
      healthInsuranceNumber: json['health_insurance_number'],
      nationality: json['nationality'],
      patientId: json['patient_id'],
    );
  }
}
