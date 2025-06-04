class StaffReqParams {
  final String dateOfBirth;
  final String department;
  final String fullName;
  final String gender;

  StaffReqParams({
    required this.dateOfBirth,
    required this.department,
    required this.fullName,
    required this.gender,
  });

  Map<String, dynamic> toJson() {
    return {
      'date_of_birth': dateOfBirth,
      'department': department,
      'full_name': fullName,
      'gender': gender,
    };
  }
}
