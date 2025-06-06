import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/features/prescriptions/domain/entities/medications.dart';
import 'package:merema/features/prescriptions/domain/usecases/get_medication_by_id.dart';
import 'package:merema/features/prescriptions/domain/usecases/get_medications.dart';
import 'package:merema/features/prescriptions/presentation/bloc/medications_state.dart';
import 'package:merema/core/services/service_locator.dart';

class MedicationsCubit extends Cubit<MedicationsState> {
  MedicationsCubit() : super(MedicationsInitial());

  Map<int, Medication> _medicationsMap = {};

  void setMedications(List<Medication> medications) {
    _medicationsMap = {for (var med in medications) med.medId: med};
    emit(MedicationsLoaded(medications));
  }

  Medication? getMedicationById(int medId) {
    return _medicationsMap[medId];
  }

  Future<void> fetchMedicationById(int medId) async {
    if (_medicationsMap.containsKey(medId)) {
      return;
    }

    final result = await sl<GetMedicationByIdUseCase>().call(medId);

    result.fold(
      (failure) => emit(MedicationError(failure.toString())),
      (medication) {
        _medicationsMap[medId] = medication;
        emit(MedicationLoaded(medication));
      },
    );
  }

  Future<void> getAllMedications() async {
    emit(MedicationLoading());

    final result = await sl<GetMedicationsUseCase>().call(null);

    result.fold(
      (failure) => emit(MedicationError(failure.toString())),
      (medicationsModel) {
        final medsList = medicationsModel.medications ?? [];
        _medicationsMap = {for (var med in medsList) med.medId: med};
        emit(MedicationsLoaded(medsList));
      },
    );
  }
}
