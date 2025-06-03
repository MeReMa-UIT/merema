class PatientRegisterReqParams {
  final String address;
  final String dateOfBirth;
  final String emergencyContactInfo;
  final String ethnicity;
  final String fullName;
  final String gender;
  final String healthInsuranceExpiredDate;
  final String healthInsuranceNumber;
  final String nationality;

  PatientRegisterReqParams({
    required this.address,
    required this.dateOfBirth,
    required this.emergencyContactInfo,
    required this.ethnicity,
    required this.fullName,
    required this.gender,
    required this.healthInsuranceExpiredDate,
    required this.healthInsuranceNumber,
    required this.nationality,
  });

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'date_of_birth': dateOfBirth,
      'emergency_contact_info': emergencyContactInfo,
      'ethnicity': ethnicity,
      'full_name': fullName,
      'gender': gender,
      'health_insurance_expired_date': healthInsuranceExpiredDate,
      'health_insurance_number': healthInsuranceNumber,
      'nationality': nationality,
    };
  }
}
