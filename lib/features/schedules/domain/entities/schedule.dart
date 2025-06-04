class Schedule {
  final String examinationDate;
  final String expectedReceptionTime;
  final int queueNumber;
  final int scheduleId;
  late final int status;
  final int type;

  Schedule({
    required this.examinationDate,
    required this.expectedReceptionTime,
    required this.queueNumber,
    required this.scheduleId,
    required this.status,
    required this.type,
  });
}
