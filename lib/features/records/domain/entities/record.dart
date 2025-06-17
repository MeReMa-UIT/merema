import 'package:equatable/equatable.dart';

class Record extends Equatable {
  final int doctorId;
  final int patientId;
  final String primaryDiagnosis;
  final int recordId;
  final String? secondaryDiagnosis;
  final String typeId;

  const Record({
    required this.doctorId,
    required this.patientId,
    required this.primaryDiagnosis,
    required this.recordId,
    this.secondaryDiagnosis,
    required this.typeId,
  });

  @override
  List<Object?> get props => [
        doctorId,
        patientId,
        primaryDiagnosis,
        recordId,
        secondaryDiagnosis,
        typeId,
      ];
}
