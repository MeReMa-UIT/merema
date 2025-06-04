import 'package:merema/features/patients/domain/entities/patient_brief_infos.dart';

class PatientsBriefInfosModel extends PatientsBriefInfos {
  const PatientsBriefInfosModel({
    required super.patients,
  });

  factory PatientsBriefInfosModel.fromJson(List<dynamic> json) {
    final patientsList = json.map((patientJson) {
      final patientData = patientJson as Map<String, dynamic>;
      return PatientBriefInfos(
        dateOfBirth: patientData['date_of_birth'].toString(),
        fullName: patientData['full_name'],
        gender: patientData['gender'],
        patientId: patientData['patient_id'],
      );
    }).toList();

    return PatientsBriefInfosModel(
      patients: patientsList,
    );
  }
}
