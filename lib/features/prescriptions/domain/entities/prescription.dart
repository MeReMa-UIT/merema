import 'package:equatable/equatable.dart';

class PrescriptionDetails extends Equatable {
  final double afternoonDosage;
  final String dosageUnit;
  final int durationDays;
  final double eveningDosage;
  final String instructions;
  final int medId;
  final double morningDosage;
  final double totalDosage;

  const PrescriptionDetails({
    required this.afternoonDosage,
    required this.dosageUnit,
    required this.durationDays,
    required this.eveningDosage,
    required this.instructions,
    required this.medId,
    required this.morningDosage,
    required this.totalDosage,
  });

  PrescriptionDetails copyWith({
    int? detailId,
    double? afternoonDosage,
    String? dosageUnit,
    int? durationDays,
    double? eveningDosage,
    String? instructions,
    int? medId,
    double? morningDosage,
    double? totalDosage,
  }) {
    return PrescriptionDetails(
      afternoonDosage: afternoonDosage ?? this.afternoonDosage,
      dosageUnit: dosageUnit ?? this.dosageUnit,
      durationDays: durationDays ?? this.durationDays,
      eveningDosage: eveningDosage ?? this.eveningDosage,
      instructions: instructions ?? this.instructions,
      medId: medId ?? this.medId,
      morningDosage: morningDosage ?? this.morningDosage,
      totalDosage: totalDosage ?? this.totalDosage,
    );
  }

  @override
  List<Object?> get props => [
        afternoonDosage,
        dosageUnit,
        durationDays,
        eveningDosage,
        instructions,
        medId,
        morningDosage,
        totalDosage,
      ];
}

class Prescription extends Equatable {
  final List<PrescriptionDetails> details;
  final bool isInsuranceCovered;
  final String prescriptionNote;
  final int recordId;

  const Prescription({
    required this.details,
    required this.isInsuranceCovered,
    required this.prescriptionNote,
    required this.recordId,
  });

  @override
  List<Object?> get props => [
        details,
        isInsuranceCovered,
        prescriptionNote,
        recordId,
      ];
}

class PrescriptionResponse extends Equatable {
  final String createdAt;
  final bool isInsuranceCovered;
  final int prescriptionId;
  final String prescriptionNote;
  final String? receivedAt;
  final int recordId;

  const PrescriptionResponse({
    required this.createdAt,
    required this.isInsuranceCovered,
    required this.prescriptionId,
    required this.prescriptionNote,
    this.receivedAt,
    required this.recordId,
  });

  @override
  List<Object?> get props => [
        createdAt,
        isInsuranceCovered,
        prescriptionId,
        prescriptionNote,
        receivedAt,
        recordId,
      ];
}
