import 'package:merema/features/records/domain/entities/record.dart';

class RecordModel extends Record {
  const RecordModel({
    required super.doctorId,
    required super.patientId,
    required super.primaryDiagnosis,
    required super.recordId,
    super.secondaryDiagnosis,
    required super.typeId,
  });

  factory RecordModel.fromJson(Map<String, dynamic> json) {
    return RecordModel(
      doctorId: json['doctor_id'] as int,
      patientId: json['patient_id'] as int,
      primaryDiagnosis: json['primary_diagnosis'] as String,
      recordId: json['record_id'] as int,
      secondaryDiagnosis: json['secondary_diagnosis'] as String?,
      typeId: json['type_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctor_id': doctorId,
      'patient_id': patientId,
      'primary_diagnosis': primaryDiagnosis,
      'record_id': recordId,
      'secondary_diagnosis': secondaryDiagnosis,
      'type_id': typeId,
    };
  }
}
