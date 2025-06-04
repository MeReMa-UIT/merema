import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/patients/domain/usecases/get_patients_list.dart';
import 'package:merema/features/patients/presentation/bloc/patients_state.dart';

class PatientsCubit extends Cubit<PatientsState> {
  PatientsCubit() : super(PatientsInitial());

  Future<void> getPatients() async {
    emit(PatientsLoading());

    final result = await sl<GetPatientsListUseCase>().call(null);

    result.fold(
      (error) => emit(PatientsError(error.toString())),
      (patientBriefInfos) {
        final patients = patientBriefInfos.patients;
        emit(PatientsLoaded(
          allPatients: patients,
          filteredPatients: List.from(patients),
        ));
      },
    );
  }

  void searchPatients({
    String searchQuery = '',
  }) {
    final currentState = state;
    if (currentState is PatientsLoaded) {
      final filteredPatients = currentState.allPatients.where((patient) {
        return searchQuery.isEmpty ||
            patient.fullName
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            patient.dateOfBirth
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            patient.gender.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();

      emit(currentState.copyWith(filteredPatients: filteredPatients));
    }
  }

  void clearSearch() {
    final currentState = state;
    if (currentState is PatientsLoaded) {
      emit(currentState.copyWith(
        filteredPatients: List.from(currentState.allPatients),
      ));
    }
  }
}
