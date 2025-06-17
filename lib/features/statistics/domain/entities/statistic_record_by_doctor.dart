import 'package:merema/features/statistics/domain/entities/statistic_record.dart';

class StatisticRecordByDoctor {
  final List<StatisticRecord>? amountByTime;
  final int doctorId;
  final int totalAmount;

  const StatisticRecordByDoctor({
    this.amountByTime,
    required this.doctorId,
    required this.totalAmount,
  });
}
