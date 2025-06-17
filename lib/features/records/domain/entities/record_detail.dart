import 'package:equatable/equatable.dart';

class RecordDetail extends Equatable {
  final String createdAt;
  final int doctorId;
  final String? expiredAt;
  final int patientId;
  final Map<String, dynamic> recordDetail;
  final int recordId;
  final String typeId;

  const RecordDetail({
    required this.createdAt,
    required this.doctorId,
    this.expiredAt,
    required this.patientId,
    required this.recordDetail,
    required this.recordId,
    required this.typeId,
  });

  @override
  List<Object?> get props => [
        createdAt,
        doctorId,
        expiredAt,
        patientId,
        recordDetail,
        recordId,
        typeId,
      ];
}
