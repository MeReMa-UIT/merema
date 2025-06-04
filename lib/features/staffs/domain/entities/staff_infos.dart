class StaffInfos {
  final String dateOfBirth;
  final String department;
  final String fullName;
  final String gender;
  final int staffId;

  const StaffInfos({
    required this.dateOfBirth,
    required this.department,
    required this.fullName,
    required this.gender,
    required this.staffId,
  });
}

class StaffsInfos {
  final List<StaffInfos> staffs;

  const StaffsInfos({
    required this.staffs,
  });
}
