import 'package:merema/features/schedules/domain/entities/schedule.dart';

class ScheduleModel extends Schedule {
  ScheduleModel({
    required super.examinationDate,
    required super.expectedReceptionTime,
    required super.queueNumber,
    required super.scheduleId,
    required super.status,
    required super.type,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      examinationDate: json['examination_date'],
      expectedReceptionTime: json['expected_reception_time'],
      queueNumber: json['queue_number'],
      scheduleId: json['schedule_id'],
      status: json['status'],
      type: json['type'],
    );
  }
}

class SchedulesModel {
  final List<ScheduleModel> schedules;

  SchedulesModel({required this.schedules});

  factory SchedulesModel.fromJson(List<dynamic> json) {
    return SchedulesModel(
      schedules: json.map((item) => ScheduleModel.fromJson(item)).toList(),
    );
  }
}
