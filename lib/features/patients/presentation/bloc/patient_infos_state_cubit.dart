import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/patients/domain/usecases/get_patient_infos.dart';
import 'package:merema/features/patients/presentation/bloc/patient_infos_state.dart';

class PatientInfosCubit extends Cubit<PatientInfosState> {
  PatientInfosCubit() : super(PatientInfosInitial());

  Future<void> getInfos(int patientId) async {
    emit(PatientInfosLoading());

    final result = await sl<GetPatientInfosUseCase>().call(patientId);

    result.fold(
      (error) => emit(PatientInfosError(error.toString())),
      (patientInfo) {
        emit(PatientInfosLoaded(patientInfo: patientInfo));
      },
    );
  }
}
