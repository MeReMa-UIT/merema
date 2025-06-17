import 'package:merema/features/statistics/domain/entities/statistic_record_by_doctor.dart';
import 'package:merema/features/statistics/data/models/statistic_record_model.dart';

class StatisticRecordByDoctorModel extends StatisticRecordByDoctor {
  const StatisticRecordByDoctorModel({
    super.amountByTime,
    required super.doctorId,
    required super.totalAmount,
  });

  factory StatisticRecordByDoctorModel.fromJson(Map<String, dynamic> json) {
    final amountByTimeData = json['amount_by_time'] as List<dynamic>?;
    final amountByTimeList = amountByTimeData
        ?.map((item) => StatisticRecordModel.fromJson(item))
        .toList();

    return StatisticRecordByDoctorModel(
      amountByTime: amountByTimeList,
      doctorId: json['doctor_id'] as int,
      totalAmount: json['total_amount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount_by_time': amountByTime
          ?.map((record) => (record as StatisticRecordModel).toJson())
          .toList(),
      'doctor_id': doctorId,
      'total_amount': totalAmount,
    };
  }
}
