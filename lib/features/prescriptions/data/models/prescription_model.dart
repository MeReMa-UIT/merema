import 'package:merema/features/prescriptions/domain/entities/prescription.dart';

class PrescriptionDetailModel extends PrescriptionDetail {
  const PrescriptionDetailModel({
    required super.afternoonDosage,
    required super.dosageUnit,
    required super.durationDays,
    required super.eveningDosage,
    required super.instructions,
    required super.medId,
    required super.morningDosage,
    required super.totalDosage,
  });

  factory PrescriptionDetailModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionDetailModel(
      afternoonDosage: json['afternoon_dosage'],
      dosageUnit: json['dosage_unit'],
      durationDays: json['duration_days'],
      eveningDosage: json['evening_dosage'],
      instructions: json['instructions'],
      medId: json['med_id'],
      morningDosage: json['morning_dosage'],
      totalDosage: json['total_dosage'],
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
    final detailsList = (json['details'] as List<dynamic>)
        .map((detailJson) => PrescriptionDetailModel.fromJson(detailJson))
        .toList();

    return PrescriptionModel(
      details: detailsList,
      isInsuranceCovered: json['is_insurance_covered'],
      prescriptionNote: json['prescription_note'],
      recordId: json['record_id'],
    );
  }
}
