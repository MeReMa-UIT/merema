import 'package:dartz/dartz.dart';
import 'package:merema/features/patients/domain/entities/patient_brief_infos.dart';
import 'package:merema/features/patients/domain/entities/patient_infos.dart';
import 'package:merema/core/layers/data/model/account_req_params.dart';
import 'package:merema/features/patients/data/models/patient_req_params.dart';

abstract class PatientRepository {
  Future<Either<Error, PatientsBriefInfos>> getPatientsList(String token);
  Future<Either<Error, PatientInfos>> getPatientInfos(
      int patientId, String token);
  Future<Either<Error, dynamic>> registerPatient(
    AccountReqParams accountParams,
    PatientReqParams patientParams,
    String token,
  );
  Future<Either<Error, dynamic>> updatePatient(
    PatientReqParams patientParams,
    int patientId,
    String token,
  );
}
