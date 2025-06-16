import 'package:merema/features/records/domain/entities/record.dart';
import 'package:merema/features/records/domain/entities/record_detail.dart';

abstract class RecordsState {}

class RecordsInitial extends RecordsState {}

class RecordsLoading extends RecordsState {}

class RecordsLoaded extends RecordsState {
  final List<Record> allRecords;
  final List<Record> filteredRecords;
  final Map<String, String> recordTypesMap;

  RecordsLoaded({
    required this.allRecords,
    required this.filteredRecords,
    this.recordTypesMap = const {},
  });

  RecordsLoaded copyWith({
    List<Record>? allRecords,
    List<Record>? filteredRecords,
    Map<String, String>? recordTypesMap,
  }) {
    return RecordsLoaded(
      allRecords: allRecords ?? this.allRecords,
      filteredRecords: filteredRecords ?? this.filteredRecords,
      recordTypesMap: recordTypesMap ?? this.recordTypesMap,
    );
  }
}

class RecordsError extends RecordsState {
  final String message;

  RecordsError(this.message);
}

class RecordDetailsLoading extends RecordsState {}

class RecordDetailsLoaded extends RecordsState {
  final RecordDetail recordDetail;

  RecordDetailsLoaded({
    required this.recordDetail,
  });
}
