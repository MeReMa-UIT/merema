import 'package:dartz/dartz.dart';
import 'package:merema/features/prescriptions/domain/entities/medications.dart';
import 'package:merema/features/prescriptions/domain/entities/prescription.dart';

abstract class PrescriptionRepository {
  Future<Either<Error, Prescription>> createPrescription(
    Map<String, dynamic> prescriptionData,
    String token,
  );

  Future<Either<Error, List<Prescription>>> getPrescriptionsByPatientId(
    int patientId,
    String token,
  );

  Future<Either<Error, List<Prescription>>> getPrescriptionsByRecordId(
    int recordId,
    String token,
  );

  Future<Either<Error, List<PrescriptionDetail>>> getPrescriptionDetails(
    int prescriptionId,
    String token,
  );

  Future<Either<Error, Prescription>> updatePrescription(
    int prescriptionId,
    Map<String, dynamic> updates,
    String token,
  );

  Future<Either<Error, dynamic>> confirmReceived(
    int prescriptionId,
    String token,
  );

  Future<Either<Error, Medications>> getMedications(String token);

  Future<Either<Error, Medication>> getMedicationById(
    int medicationId,
    String token,
  );
}
