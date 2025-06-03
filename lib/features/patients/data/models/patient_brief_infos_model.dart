import 'package:merema/features/patients/domain/entities/patient_brief_infos.dart';

class PatientBriefInfosModel extends PatientBriefInfos {
  const PatientBriefInfosModel({
    required super.patients,
  });

  factory PatientBriefInfosModel.fromJson(List<dynamic> json) {
    final patientsList = json.map((patientJson) {
      final patientData = patientJson as Map<String, dynamic>;
      return PatientBriefInfo(
        dateOfBirth: patientData['date_of_birth'].toString(),
        fullName: patientData['full_name'],
        gender: patientData['gender'],
        patientId: patientData['patient_id'],
      );
    }).toList();

    return PatientBriefInfosModel(
      patients: patientsList,
    );
  }
}
