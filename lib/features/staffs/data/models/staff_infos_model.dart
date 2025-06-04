import 'package:merema/features/staffs/domain/entities/staff_infos.dart';

class StaffInfosModel extends StaffInfos {
  const StaffInfosModel({
    required super.dateOfBirth,
    required super.department,
    required super.fullName,
    required super.gender,
    required super.staffId,
  });

  factory StaffInfosModel.fromJson(Map<String, dynamic> json) {
    return StaffInfosModel(
      dateOfBirth: json['date_of_birth'].toString(),
      department: json['department'],
      fullName: json['full_name'],
      gender: json['gender'],
      staffId: json['staff_id'],
    );
  }
}

class StaffsInfosModel extends StaffsInfos {
  const StaffsInfosModel({
    required super.staffs,
  });

  factory StaffsInfosModel.fromJson(List<dynamic> json) {
    final staffsList =
        json.map((staffJson) => StaffInfosModel.fromJson(staffJson)).toList();

    return StaffsInfosModel(
      staffs: staffsList,
    );
  }
}
