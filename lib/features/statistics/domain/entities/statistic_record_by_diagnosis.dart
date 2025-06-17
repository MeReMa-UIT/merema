import 'package:merema/features/statistics/domain/entities/statistic_record.dart';

class StatisticRecordByDiagnosis {
  final List<StatisticRecord>? amountByTime;
  final String diagnosisId;
  final int totalAmount;

  const StatisticRecordByDiagnosis({
    this.amountByTime,
    required this.diagnosisId,
    required this.totalAmount,
  });
}
