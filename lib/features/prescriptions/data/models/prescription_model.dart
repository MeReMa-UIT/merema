import 'package:merema/features/prescriptions/domain/entities/prescription.dart';

class PrescriptionDetailsModel extends PrescriptionDetails {
  const PrescriptionDetailsModel({
    super.detailId,
    required super.afternoonDosage,
    required super.dosageUnit,
    required super.durationDays,
    required super.eveningDosage,
    required super.instructions,
    required super.medId,
    required super.morningDosage,
    required super.totalDosage,
  });

  factory PrescriptionDetailsModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionDetailsModel(
      detailId: json['detail_id'],
      afternoonDosage: double.parse(json['afternoon_dosage'].toString()),
      dosageUnit: json['dosage_unit'],
      durationDays: json['duration_days'],
      eveningDosage: double.parse(json['evening_dosage'].toString()),
      instructions: json['instructions'],
      medId: json['med_id'],
      morningDosage: double.parse(json['morning_dosage'].toString()),
      totalDosage: double.parse(json['total_dosage'].toString()),
    );
  }
}

class PrescriptionModel extends Prescription {
  const PrescriptionModel({
    required super.details,
    required super.isInsuranceCovered,
    required super.prescriptionNote,
    required super.recordId,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    final detailsList = (json['details'] as List<dynamic>?)
            ?.map((detailJson) => PrescriptionDetailsModel.fromJson(detailJson))
            .toList() ??
        <PrescriptionDetailsModel>[];

    return PrescriptionModel(
      details: detailsList,
      isInsuranceCovered: json['is_insurance_covered'] ?? false,
      prescriptionNote: json['prescription_note'] ?? '',
      recordId: json['record_id'] ?? 0,
    );
  }
}

class PrescriptionResponseModel extends PrescriptionResponse {
  const PrescriptionResponseModel({
    required super.createdAt,
    required super.isInsuranceCovered,
    required super.prescriptionId,
    required super.prescriptionNote,
    super.receivedAt,
    required super.recordId,
  });

  factory PrescriptionResponseModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionResponseModel(
      createdAt: json['created_at'],
      isInsuranceCovered: json['is_insurance_covered'],
      prescriptionId: json['prescription_id'],
      prescriptionNote: json['prescription_note'],
      receivedAt: json['received_at'],
      recordId: json['record_id'],
    );
  }
}
