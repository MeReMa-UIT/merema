import 'package:merema/features/records/domain/entities/record_detail.dart';

class RecordDetailModel extends RecordDetail {
  const RecordDetailModel({
    required super.createdAt,
    required super.doctorId,
    required super.expiredAt,
    required super.patientId,
    required super.recordDetail,
    required super.recordId,
    required super.typeId,
  });

  factory RecordDetailModel.fromJson(Map<String, dynamic> json) {
    return RecordDetailModel(
      createdAt: json['created_at'] as String,
      doctorId: json['doctor_id'] as int,
      expiredAt: json['expired_at'] as String,
      patientId: json['patient_id'] as int,
      recordDetail: json['record_detail'] as Map<String, dynamic>,
      recordId: json['record_id'] as int,
      typeId: json['type_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'doctor_id': doctorId,
      'expired_at': expiredAt,
      'patient_id': patientId,
      'record_detail': recordDetail,
      'record_id': recordId,
      'type_id': typeId,
    };
  }
}
