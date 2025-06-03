import 'package:dartz/dartz.dart';
import 'package:merema/core/network/dio_client.dart';
import 'package:merema/core/utils/error_handler.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/patients/data/models/patient_brief_infos_model.dart';
import 'package:merema/features/patients/data/models/patient_infos_model.dart';

abstract class PatientApiService {
  Future<Either<ApiError, PatientBriefInfosModel>> fetchPatientsList(
      String token);
  Future<Either<ApiError, PatientInfosModel>> fetchPatientInfos(
      int patientId, String token);
  Future<Either<ApiError, dynamic>> registerAccount(
      Map<String, dynamic> data, String token);
  Future<Either<ApiError, dynamic>> createAccount(
      Map<String, dynamic> data, String token);
  Future<Either<ApiError, dynamic>> registerPatient(
      Map<String, dynamic> data, String token);
}

class PatientApiServiceImpl implements PatientApiService {
  @override
  Future<Either<ApiError, PatientBriefInfosModel>> fetchPatientsList(
      String token) async {
    try {
      final response = await sl<DioClient>().get(
        '/patients',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final patientBriefInfosModel =
          PatientBriefInfosModel.fromJson(response.data);

      return Right(patientBriefInfosModel);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<ApiError, PatientInfosModel>> fetchPatientInfos(
      int patientId, String token) async {
    try {
      final response = await sl<DioClient>().get(
        '/patients/$patientId',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final patientInfosModel = PatientInfosModel.fromJson(response.data);

      return Right(patientInfosModel);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<ApiError, dynamic>> registerAccount(
      Map<String, dynamic> data, String token) async {
    try {
      final response = await sl<DioClient>().post(
        '/accounts/register',
        data: data,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return Right(response.data);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<ApiError, dynamic>> createAccount(
      Map<String, dynamic> data, String token) async {
    try {
      final response = await sl<DioClient>().post(
        '/accounts/register/create',
        data: data,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return Right(response.data);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<ApiError, dynamic>> registerPatient(
      Map<String, dynamic> data, String token) async {
    try {
      final response = await sl<DioClient>().post(
        '/accounts/register/patients',
        data: data,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return Right(response.data);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }
}
