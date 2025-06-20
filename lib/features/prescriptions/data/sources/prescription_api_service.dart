import 'package:dartz/dartz.dart';
import 'package:merema/core/network/dio_client.dart';
import 'package:merema/core/utils/error_handler.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/prescriptions/data/models/prescription_model.dart';
import 'package:merema/features/prescriptions/data/models/medications_model.dart';

abstract class PrescriptionApiService {
  Future<Either<ApiError, int>> createPrescription(
    Map<String, dynamic> prescriptionData,
    String token,
  );
  Future<Either<ApiError, List<PrescriptionResponseModel>>>
      fetchPrescriptionsByPatientId(
    int patientId,
    String token,
  );
  Future<Either<ApiError, PrescriptionResponseModel>>
      fetchPrescriptionsByRecordId(
    int recordId,
    String token,
  );
  Future<Either<ApiError, List<PrescriptionDetailsModel>>>
      fetchPrescriptionDetails(
    int prescriptionId,
    String token,
  );
  Future<Either<ApiError, PrescriptionModel>> updatePrescription(
    int prescriptionId,
    Map<String, dynamic> updates,
    String token,
  );
  Future<Either<ApiError, dynamic>> confirmReceived(
    int prescriptionId,
    String token,
  );
  Future<Either<ApiError, MedicationsModel>> fetchMedications(String token);

  Future<Either<ApiError, MedicationModel>> fetchMedicationById(
    int medicationId,
    String token,
  );

  Future<Either<ApiError, dynamic>> updatePrescriptionMedication(
    int prescriptionId,
    int medId,
    Map<String, dynamic> updates,
    String token,
  );
  Future<Either<ApiError, dynamic>> deletePrescriptionMedication(
    int prescriptionId,
    int medId,
    String token,
  );

  Future<Either<ApiError, dynamic>> addPrescriptionMedication(
    int prescriptionId,
    List<Map<String, dynamic>> medData,
    String token,
  );
}

class PrescriptionApiServiceImpl implements PrescriptionApiService {
  @override
  Future<Either<ApiError, int>> createPrescription(
    Map<String, dynamic> prescriptionData,
    String token,
  ) async {
    try {
      final response = await sl<DioClient>().post(
        '/prescriptions',
        data: prescriptionData,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final prescriptionId = response.data['prescription_id'];
      return Right(prescriptionId);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<ApiError, List<PrescriptionResponseModel>>>
      fetchPrescriptionsByPatientId(
    int patientId,
    String token,
  ) async {
    try {
      final response = await sl<DioClient>().get(
        '/prescriptions/patients/$patientId',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final prescriptionsList = (response.data as List<dynamic>)
          .map((prescriptionJson) =>
              PrescriptionResponseModel.fromJson(prescriptionJson))
          .toList();
      return Right(prescriptionsList);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<ApiError, PrescriptionResponseModel>>
      fetchPrescriptionsByRecordId(
    int recordId,
    String token,
  ) async {
    try {
      final response = await sl<DioClient>().get(
        '/prescriptions/records/$recordId',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final prescription = PrescriptionResponseModel.fromJson(response.data);
      return Right(prescription);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<ApiError, List<PrescriptionDetailsModel>>>
      fetchPrescriptionDetails(
    int prescriptionId,
    String token,
  ) async {
    try {
      final response = await sl<DioClient>().get(
        '/prescriptions/$prescriptionId',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final prescriptionDetailsList = (response.data as List<dynamic>)
          .map((detailJson) => PrescriptionDetailsModel.fromJson(detailJson))
          .toList();
      return Right(prescriptionDetailsList);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<ApiError, PrescriptionModel>> updatePrescription(
    int prescriptionId,
    Map<String, dynamic> updates,
    String token,
  ) async {
    try {
      final response = await sl<DioClient>().put(
        '/prescriptions/$prescriptionId',
        data: updates,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final prescriptionModel = PrescriptionModel.fromJson(response.data);
      return Right(prescriptionModel);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<ApiError, dynamic>> confirmReceived(
    int prescriptionId,
    String token,
  ) async {
    try {
      final response = await sl<DioClient>().put(
        '/prescriptions/$prescriptionId/confirm',
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
  Future<Either<ApiError, MedicationsModel>> fetchMedications(
      String token) async {
    try {
      final response = await sl<DioClient>().get(
        '/catalog/medications',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final medicationsModel = MedicationsModel.fromJson(response.data);
      return Right(medicationsModel);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<ApiError, MedicationModel>> fetchMedicationById(
    int medicationId,
    String token,
  ) async {
    try {
      final response = await sl<DioClient>().get(
        '/catalog/medications/$medicationId',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final medicationModel = MedicationModel.fromJson(response.data);
      return Right(medicationModel);
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<ApiError, dynamic>> updatePrescriptionMedication(
    int prescriptionId,
    int medId,
    Map<String, dynamic> updates,
    String token,
  ) async {
    try {
      final response = await sl<DioClient>().put(
        '/prescriptions/$prescriptionId/$medId',
        data: updates,
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
  Future<Either<ApiError, dynamic>> deletePrescriptionMedication(
    int prescriptionId,
    int medId,
    String token,
  ) async {
    try {
      final response = await sl<DioClient>().delete(
        '/prescriptions/$prescriptionId/$medId',
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
  Future<Either<ApiError, dynamic>> addPrescriptionMedication(
    int prescriptionId,
    List<Map<String, dynamic>> medData,
    String token,
  ) async {
    try {
      final response = await sl<DioClient>().post(
        '/prescriptions/$prescriptionId',
        data: medData,
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
