import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/records/domain/usecases/get_records.dart';
import 'package:merema/features/records/domain/usecases/get_record_details.dart';
import 'package:merema/features/records/domain/usecases/get_record_types.dart';
import 'package:merema/features/records/presentation/bloc/records_state.dart';

class RecordsCubit extends Cubit<RecordsState> {
  RecordsCubit() : super(RecordsInitial());

  Map<String, String> _recordTypesMap = {};

  String getRecordTypeName(String typeId) {
    return _recordTypesMap[typeId] ?? 'Unknown Type';
  }

  Future<void> getAllRecords() async {
    emit(RecordsLoading());

    try {
      await _loadRecordTypes();

      final result = await sl<GetRecordsUseCase>().call(null);

      result.fold(
        (error) => emit(RecordsError(error.toString())),
        (records) => emit(RecordsLoaded(
          allRecords: records,
          filteredRecords: List.from(records),
          recordTypesMap: _recordTypesMap,
        )),
      );
    } catch (e) {
      emit(RecordsError(e.toString()));
    }
  }

  Future<void> _loadRecordTypes() async {
    try {
      final result = await sl<GetRecordTypesUseCase>().call(null);
      result.fold(
        (error) {
          _recordTypesMap = {};
        },
        (recordTypesData) {
          _recordTypesMap = {};
          if (recordTypesData is List) {
            for (var recordType in recordTypesData) {
              if (recordType != null) {
                try {
                  final typeId = recordType.typeId?.toString() ?? '';
                  final typeName = recordType.typeName?.toString() ?? 'Unknown';
                  if (typeId.isNotEmpty) {
                    _recordTypesMap[typeId] = typeName;
                  }
                } catch (e) {
                  debugPrint(
                    'Error processing record type: $e',
                  );
                }
              }
            }
          }
        },
      );
    } catch (e) {
      _recordTypesMap = {};
    }
  }

  Future<void> getRecordsByPatient(int patientId) async {
    final currentState = state;
    if (currentState is RecordsLoaded) {
      final filteredRecords = currentState.allRecords
          .where((record) => record.patientId == patientId)
          .toList();

      emit(currentState.copyWith(filteredRecords: filteredRecords));
    } else {
      await getAllRecords();
      final newState = state;
      if (newState is RecordsLoaded) {
        final filteredRecords = newState.allRecords
            .where((record) => record.patientId == patientId)
            .toList();

        emit(newState.copyWith(filteredRecords: filteredRecords));
      }
    }
  }

  void showAllRecords() {
    final currentState = state;
    if (currentState is RecordsLoaded) {
      emit(currentState.copyWith(
        filteredRecords: List.from(currentState.allRecords),
      ));
    }
  }

  Future<void> getRecordDetails(int recordId) async {
    emit(RecordDetailsLoading());

    try {
      final result = await sl<GetRecordDetailsUseCase>().call(recordId);

      result.fold(
        (error) => emit(RecordsError(error.toString())),
        (recordDetail) => emit(RecordDetailsLoaded(recordDetail: recordDetail)),
      );
    } catch (e) {
      emit(RecordsError(e.toString()));
    }
  }

  void restoreRecordsState(RecordsState state) {
    emit(state);
  }
}
