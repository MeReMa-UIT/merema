import 'package:dartz/dartz.dart';
import 'package:merema/core/layers/data/sources/register_api_service.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/utils/error_handler.dart';
import 'package:merema/features/patients/domain/entities/patient_brief_infos.dart';
import 'package:merema/features/patients/domain/entities/patient_infos.dart';
import 'package:merema/features/patients/domain/repositories/patient_repository.dart';
import '../sources/patient_api_service.dart';
import 'package:merema/core/layers/data/model/account_req_params.dart';
import 'package:merema/features/patients/data/models/patient_req_params.dart';

class PatientRepositoryImpl extends PatientRepository {
  @override
  Future<Either<Error, PatientsBriefInfos>> getPatientsList(String token) async {
    try {
      final result = await sl<PatientApiService>().fetchPatientsList(token);

      return result.fold(
        (error) => Left(error),
        (patientsList) => Right(patientsList),
      );
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<Error, PatientInfos>> getPatientInfos(
      int patientId, String token) async {
    try {
      final result =
          await sl<PatientApiService>().fetchPatientInfos(patientId, token);

      return result.fold(
        (error) => Left(error),
        (patientInfo) => Right(patientInfo),
      );
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<Error, dynamic>> registerPatient(
    AccountReqParams accountParams,
    PatientReqParams patientParams,
    String token,
  ) async {
    try {
      final regAccResult = await sl<RegisterApiService>().registerAccount({
        'citizen_id': accountParams.citizenId,
      }, token);
      if (regAccResult.isLeft()) {
        return Left(regAccResult.fold((l) => l,
            (r) => ApiErrorHandler.handleError('Registration failed')));
      }

      final regAccData = regAccResult.getOrElse(() => {});
      var accId = regAccData['acc_id'];
      var registerToken = regAccData['token'];

      if (accId == -1) {
        final createAccResult = await sl<RegisterApiService>().createAccount(
          accountParams.toJson(),
          registerToken,
        );
        if (createAccResult.isLeft()) {
          return Left(createAccResult.fold((l) => l,
              (r) => ApiErrorHandler.handleError('Account creation failed')));
        }

        final createAccData = createAccResult.getOrElse(() => {});
        accId = createAccData['acc_id'];
        registerToken = createAccData['token'];
      }

      final patientRequest = accId == -1
          ? {...patientParams.toJson()}
          : {'acc_id': accId, ...patientParams.toJson()};
      final regPatientResult = await sl<PatientApiService>().registerPatient(
        patientRequest,
        registerToken,
      );
      if (regPatientResult.isLeft()) {
        return Left(regPatientResult.fold((l) => l,
            (r) => ApiErrorHandler.handleError('Patient registration failed')));
      }

      return Right(regPatientResult.getOrElse(() => {}));
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<Error, dynamic>> updatePatient(
      PatientReqParams patientParams, int patientId, String token) async {
    try {
      final result = await sl<PatientApiService>().updatePatientInfos(
        patientParams.toJson(),
        patientId,
        token,
      );

      return result.fold(
        (error) => Left(error),
        (response) => Right(response),
      );
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }
}
