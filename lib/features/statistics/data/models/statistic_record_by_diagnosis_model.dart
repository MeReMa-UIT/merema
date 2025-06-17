import 'package:merema/features/statistics/domain/entities/statistic_record_by_diagnosis.dart';
import 'package:merema/features/statistics/data/models/statistic_record_model.dart';

class StatisticRecordByDiagnosisModel extends StatisticRecordByDiagnosis {
  const StatisticRecordByDiagnosisModel({
    super.amountByTime,
    required super.diagnosisId,
    required super.totalAmount,
  });

  factory StatisticRecordByDiagnosisModel.fromJson(Map<String, dynamic> json) {
    final amountByTimeData = json['amount_by_time'] as List<dynamic>?;
    final amountByTimeList = amountByTimeData
        ?.map((item) => StatisticRecordModel.fromJson(item))
        .toList();

    return StatisticRecordByDiagnosisModel(
      amountByTime: amountByTimeList,
      diagnosisId: json['diagnosis_id'] as String,
      totalAmount: json['total_amount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount_by_time': amountByTime
          ?.map((record) => (record as StatisticRecordModel).toJson())
          .toList(),
      'diagnosis_id': diagnosisId,
      'total_amount': totalAmount,
    };
  }
}
