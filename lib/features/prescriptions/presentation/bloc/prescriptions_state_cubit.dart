import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/features/prescriptions/domain/usecases/get_prescriptions_by_patient.dart';
import 'package:merema/features/prescriptions/domain/usecases/get_prescriptions_by_record.dart';
import 'package:merema/features/prescriptions/domain/usecases/get_prescription_details.dart';
import 'package:merema/features/prescriptions/presentation/bloc/prescriptions_state.dart';
import 'package:merema/core/services/service_locator.dart';

class PrescriptionsCubit extends Cubit<PrescriptionsState> {
  PrescriptionsCubit() : super(PrescriptionsInitial());

  Future<void> getPrescriptionsByPatient(int patientId) async {
    if (isClosed) return;

    emit(PrescriptionsLoading());

    final result = await sl<GetPrescriptionsByPatientUseCase>().call(patientId);

    if (!isClosed) {
      result.fold(
        (failure) => emit(PrescriptionsError(failure.toString())),
        (prescriptions) => emit(PrescriptionsLoaded(prescriptions)),
      );
    }
  }

  Future<void> getPrescriptionsByRecord(int recordId) async {
    if (isClosed) return;

    emit(PrescriptionsLoading());

    try {
      final result = await sl<GetPrescriptionsByRecordUseCase>().call(recordId);

      if (!isClosed) {
        result.fold(
          (failure) {
            final errorString = failure.toString().toLowerCase();
            if (errorString.contains('404') ||
                errorString.contains('not found')) {
              emit(const PrescriptionsLoaded([]));
            } else {
              emit(PrescriptionsError(failure.toString()));
            }
          },
          (prescription) {
            if (prescription != null) {
              emit(PrescriptionsLoaded([prescription]));
            } else {
              emit(const PrescriptionsLoaded([]));
            }
          },
        );
      }
    } catch (e) {
      if (!isClosed) {
        emit(PrescriptionsError('Exception: $e'));
      }
    }
  }

  Future<void> getPrescriptionDetails(int prescriptionId) async {
    if (isClosed) return;

    emit(PrescriptionDetailsLoading());

    final result =
        await sl<GetPrescriptionDetailsUseCase>().call(prescriptionId);

    if (!isClosed) {
      result.fold(
        (failure) => emit(PrescriptionsError(failure.toString())),
        (details) => emit(PrescriptionDetailsLoaded(details)),
      );
    }
  }

  void restorePrescriptionsState(PrescriptionsState state) {
    if (!isClosed) {
      emit(state);
    }
  }
}
