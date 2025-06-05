import 'package:dartz/dartz.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/utils/error_handler.dart';
import 'package:merema/features/prescriptions/data/sources/prescription_api_service.dart';
import 'package:merema/features/prescriptions/data/sources/prescription_local_service.dart';
import 'package:merema/features/prescriptions/domain/entities/prescription.dart';
import 'package:merema/features/prescriptions/domain/entities/medications.dart';
import 'package:merema/features/prescriptions/domain/repositories/prescription_repository.dart';

class PrescriptionRepositoryImpl implements PrescriptionRepository {
  @override
  Future<Either<Error, Prescription>> createPrescription(
    Map<String, dynamic> prescriptionData,
    String token,
  ) async {
    try {
      final result = await sl<PrescriptionApiService>()
          .createPrescription(prescriptionData, token);
      return result.fold(
        (error) => Left(error),
        (prescription) => Right(prescription),
      );
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<Error, List<PrescriptionResponse>>> getPrescriptionsByPatientId(
    int patientId,
    String token,
  ) async {
    try {
      final result = await sl<PrescriptionApiService>()
          .fetchPrescriptionsByPatientId(patientId, token);
      return result.fold(
        (error) => Left(error),
        (prescriptions) => Right(prescriptions.cast<PrescriptionResponse>()),
      );
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<Error, List<PrescriptionResponse>>> getPrescriptionsByRecordId(
    int recordId,
    String token,
  ) async {
    try {
      final result = await sl<PrescriptionApiService>()
          .fetchPrescriptionsByRecordId(recordId, token);
      return result.fold(
        (error) => Left(error),
        (prescriptions) => Right(prescriptions.cast<PrescriptionResponse>()),
      );
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<Error, List<PrescriptionDetails>>> getPrescriptionDetails(
    int prescriptionId,
    String token,
  ) async {
    try {
      final result = await sl<PrescriptionApiService>()
          .fetchPrescriptionDetails(prescriptionId, token);
      return result.fold(
        (error) => Left(error),
        (prescriptionDetails) => Right(prescriptionDetails),
      );
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<Error, Prescription>> updatePrescription(
    int prescriptionId,
    Map<String, dynamic> updates,
    String token,
  ) async {
    try {
      final result = await sl<PrescriptionApiService>()
          .updatePrescription(prescriptionId, updates, token);
      return result.fold(
        (error) => Left(error),
        (prescription) => Right(prescription),
      );
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<Error, dynamic>> confirmReceived(
    int prescriptionId,
    String token,
  ) async {
    try {
      final result = await sl<PrescriptionApiService>()
          .confirmReceived(prescriptionId, token);
      return result.fold(
        (error) => Left(error),
        (response) => Right(response),
      );
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<Error, Medications>> getMedications(String token) async {
    try {
      final local = await sl<PrescriptionLocalService>().getCachedMedications();
      if (local != null) {
        return Right(local);
      }
      final result = await sl<PrescriptionApiService>().fetchMedications(token);
      return result.fold(
        (error) => Left(error),
        (medications) async {
          await sl<PrescriptionLocalService>().cacheMedications(medications);
          return Right(medications);
        },
      );
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  @override
  Future<Either<Error, Medication>> getMedicationById(
    int medicationId,
    String token,
  ) async {
    try {
      final result = await sl<PrescriptionApiService>()
          .fetchMedicationById(medicationId, token);
      return result.fold(
        (error) => Left(error),
        (medication) => Right(medication),
      );
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }
}
