import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/prescriptions/domain/usecases/get_prescriptions_by_patient.dart';
import 'package:merema/features/prescriptions/domain/usecases/get_medication_by_id.dart';
import 'package:merema/features/prescriptions/presentation/bloc/prescriptions_state.dart';

class PrescriptionsCubit extends Cubit<PrescriptionsState> {
  PrescriptionsCubit() : super(PrescriptionsInitial());

  Future<void> getPrescriptionsByPatient(int patientId) async {
    emit(PrescriptionsLoading());

    try {
      final result =
          await sl<GetPrescriptionsByPatientUseCase>().call(patientId);

      result.fold(
        (failure) {
          emit(PrescriptionsError(message: failure.toString()));
        },
        (prescriptions) async {
          Set<int> medIds = {};
          for (var prescription in prescriptions) {
            if (prescription['details'] != null &&
                prescription['details'] is List) {
              for (var detail in prescription['details']) {
                if (detail['medId'] != null) {
                  medIds.add(detail['medId'] as int);
                }
              }
            }
          }

          final Map<int, String> medicationMap = {};
          for (int medId in medIds) {
            final medicationResult =
                await sl<GetMedicationByIdUseCase>().call(medId);
            medicationResult.fold(
              (failure) {
                medicationMap[medId] = 'Unknown Medicine';
              },
              (medication) {
                if (medication is Map && medication['name'] != null) {
                  medicationMap[medId] = medication['name'];
                } else {
                  medicationMap[medId] = 'Unknown Medicine';
                }
              },
            );
          }

          emit(PrescriptionsLoaded(
            prescriptions: prescriptions,
            medications: medicationMap,
          ));
        },
      );
    } catch (e) {
      emit(PrescriptionsError(message: e.toString()));
    }
  }
}
