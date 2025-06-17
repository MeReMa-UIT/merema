import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/statistics/domain/entities/statistic_request.dart';
import 'package:merema/features/statistics/domain/usecases/get_records_statistics.dart';
import 'package:merema/features/statistics/domain/usecases/get_records_statistics_by_diagnosis.dart';
import 'package:merema/features/statistics/domain/usecases/get_records_statistics_by_doctor.dart';
import 'package:merema/features/statistics/presentation/bloc/statistics_state.dart';
import 'package:merema/features/staffs/domain/usecases/get_staffs_list.dart';
import 'package:merema/features/records/domain/usecases/get_diagnoses.dart';

class StatisticsCubit extends Cubit<StatisticsState> {
  StatisticsCubit() : super(StatisticsInitial());

  final Map<int, String> _staffNames = {};
  final Map<String, String> _diagnosisNames = {};

  String _mapToApiTimeUnit(String uiTimeUnit) {
    switch (uiTimeUnit) {
      case 'year':
        return 'month';
      case 'month':
        return 'week';
      case 'week':
        return 'day';
      default:
        return 'day';
    }
  }

  Future<void> loadStatistics({
    required String timeUnit,
    required String timestamp,
  }) async {
    emit(StatisticsLoading());

    try {
      final apiTimeUnit = _mapToApiTimeUnit(timeUnit);

      final request = StatisticRequest(
        timeUnit: apiTimeUnit,
        timestamp: timestamp,
      );

      await _loadStaffData();
      await _loadDiagnosisData();

      final results = await Future.wait([
        sl<GetRecordsStatisticsUseCase>().call(request),
        sl<GetRecordsStatisticsByDiagnosisUseCase>().call(request),
        sl<GetRecordsStatisticsByDoctorUseCase>().call(request),
      ]);

      final recordsResult = results[0];
      final diagnosisResult = results[1];
      final doctorResult = results[2];

      final hasError = recordsResult.isLeft() ||
          diagnosisResult.isLeft() ||
          doctorResult.isLeft();

      if (hasError) {
        String errorMessage = 'Failed to load statistics';
        if (recordsResult.isLeft()) {
          recordsResult.fold(
            (error) =>
                errorMessage = 'Records statistics error: ${error.toString()}',
            (_) => {},
          );
        } else if (diagnosisResult.isLeft()) {
          diagnosisResult.fold(
            (error) => errorMessage =
                'Diagnosis statistics error: ${error.toString()}',
            (_) => {},
          );
        } else if (doctorResult.isLeft()) {
          doctorResult.fold(
            (error) =>
                errorMessage = 'Doctor statistics error: ${error.toString()}',
            (_) => {},
          );
        }
        emit(StatisticsError(errorMessage));
        return;
      }

      var recordsStatistics = <dynamic>[];
      var diagnosisStatistics = <dynamic>[];
      var doctorStatistics = <dynamic>[];

      recordsResult.fold(
        (error) => {},
        (data) => recordsStatistics = data,
      );

      diagnosisResult.fold(
        (error) => {},
        (data) => diagnosisStatistics = data,
      );

      doctorResult.fold(
        (error) => {},
        (data) => doctorStatistics = data,
      );

      emit(StatisticsLoaded(
        recordsStatistics: recordsStatistics.cast(),
        diagnosisStatistics: diagnosisStatistics.cast(),
        doctorStatistics: doctorStatistics.cast(),
      ));
    } catch (e) {
      emit(StatisticsError('Unexpected error: ${e.toString()}'));
    }
  }

  Future<void> _loadStaffData() async {
    try {
      final result = await sl<GetStaffsListUseCase>().call(null);
      result.fold(
        (error) => {},
        (staffsData) {
          _staffNames.clear();
          for (var staff in staffsData.staffs) {
            _staffNames[staff.staffId] = staff.fullName;
          }
        },
      );
    } catch (e) {
      debugPrint('Error loading staff data: ${e.toString()}');
    }
  }

  Future<void> _loadDiagnosisData() async {
    try {
      final result = await sl<GetDiagnosesUseCase>().call(null);
      result.fold(
        (error) => {},
        (diagnosesData) {
          _diagnosisNames.clear();
          for (var diagnosis in diagnosesData) {
            _diagnosisNames[diagnosis.icdCode] = diagnosis.name;
          }
        },
      );
    } catch (e) {
      debugPrint('Error loading diagnosis data: ${e.toString()}');
    }
  }

  String getStaffName(int staffId) {
    return _staffNames[staffId] ?? 'Dr. $staffId';
  }

  String getDiagnosisName(String icdCode) {
    return _diagnosisNames[icdCode] ?? icdCode;
  }

  void resetState() {
    emit(StatisticsInitial());
  }
}
