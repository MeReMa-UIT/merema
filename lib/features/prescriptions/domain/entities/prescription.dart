import 'package:equatable/equatable.dart';

class PrescriptionDetail extends Equatable {
  final int afternoonDosage;
  final String dosageUnit;
  final int durationDays;
  final int eveningDosage;
  final String instructions;
  final int medId;
  final int morningDosage;
  final int totalDosage;

  const PrescriptionDetail({
    required this.afternoonDosage,
    required this.dosageUnit,
    required this.durationDays,
    required this.eveningDosage,
    required this.instructions,
    required this.medId,
    required this.morningDosage,
    required this.totalDosage,
  });

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
  final List<PrescriptionDetail> details;
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
