import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/features/prescriptions/domain/usecases/get_prescriptions_by_patient.dart';
import 'package:merema/features/prescriptions/domain/usecases/get_prescription_details.dart';
import 'package:merema/features/prescriptions/presentation/bloc/prescriptions_state.dart';
import 'package:merema/core/services/service_locator.dart';

class PrescriptionsCubit extends Cubit<PrescriptionsState> {
  PrescriptionsCubit() : super(PrescriptionsInitial());

  Future<void> getPrescriptionsByPatient(int patientId) async {
    emit(PrescriptionsLoading());

    final result = await sl<GetPrescriptionsByPatientUseCase>().call(patientId);

    result.fold(
      (failure) => emit(PrescriptionsError(failure.toString())),
      (prescriptions) => emit(PrescriptionsLoaded(prescriptions)),
    );
  }

  Future<void> getPrescriptionDetails(int prescriptionId) async {
    emit(PrescriptionDetailsLoading());

    final result =
        await sl<GetPrescriptionDetailsUseCase>().call(prescriptionId);

    result.fold(
      (failure) => emit(PrescriptionsError(failure.toString())),
      (details) => emit(PrescriptionDetailsLoaded(details)),
    );
  }

  void restorePrescriptionsState(PrescriptionsState state) {
    emit(state);
  }
}
