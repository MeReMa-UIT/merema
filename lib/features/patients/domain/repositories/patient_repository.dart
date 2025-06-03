import 'package:dartz/dartz.dart';
import 'package:merema/features/patients/domain/entities/patient_brief_infos.dart';
import 'package:merema/features/patients/domain/entities/patient_infos.dart';
import 'package:merema/core/layers/data/model/account_req_params.dart';
import 'package:merema/features/patients/data/models/patient_register_req_params.dart';

abstract class PatientRepository {
  Future<Either<Error, PatientBriefInfos>> getPatientsList(String token);
  Future<Either<Error, PatientInfo>> getPatientInfos(
      int patientId, String token);
  Future<Either<Error, dynamic>> registerPatient(
    AccountReqParams accountParams,
    PatientRegisterReqParams patientParams,
    String token,
  );
}
