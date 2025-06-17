import 'package:merema/features/statistics/domain/entities/statistic_record.dart';
import 'package:merema/features/statistics/domain/entities/statistic_record_by_diagnosis.dart';
import 'package:merema/features/statistics/domain/entities/statistic_record_by_doctor.dart';

abstract class StatisticsState {}

class StatisticsInitial extends StatisticsState {}

class StatisticsLoading extends StatisticsState {}

class StatisticsLoaded extends StatisticsState {
  final List<StatisticRecord> recordsStatistics;
  final List<StatisticRecordByDiagnosis> diagnosisStatistics;
  final List<StatisticRecordByDoctor> doctorStatistics;

  StatisticsLoaded({
    required this.recordsStatistics,
    required this.diagnosisStatistics,
    required this.doctorStatistics,
  });

  StatisticsLoaded copyWith({
    List<StatisticRecord>? recordsStatistics,
    List<StatisticRecordByDiagnosis>? diagnosisStatistics,
    List<StatisticRecordByDoctor>? doctorStatistics,
  }) {
    return StatisticsLoaded(
      recordsStatistics: recordsStatistics ?? this.recordsStatistics,
      diagnosisStatistics: diagnosisStatistics ?? this.diagnosisStatistics,
      doctorStatistics: doctorStatistics ?? this.doctorStatistics,
    );
  }
}

class StatisticsError extends StatisticsState {
  final String message;
  StatisticsError(this.message);
}
