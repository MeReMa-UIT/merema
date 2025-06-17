import 'package:merema/features/statistics/domain/entities/statistic_record.dart';

class StatisticRecordModel extends StatisticRecord {
  const StatisticRecordModel({
    required super.amount,
    required super.timestampStart,
  });

  factory StatisticRecordModel.fromJson(Map<String, dynamic> json) {
    return StatisticRecordModel(
      amount: json['amount'] as int,
      timestampStart: json['timestamp_start'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'timestamp_start': timestampStart,
    };
  }
}
