import 'package:dartz/dartz.dart';
import 'package:merema/features/prescriptions/domain/entities/medications.dart';
import 'package:merema/features/prescriptions/domain/entities/prescription.dart';

abstract class PrescriptionRepository {
  Future<Either<Error, Prescription>> createPrescription(
    Map<String, dynamic> prescriptionData,
    String token,
  );

  Future<Either<Error, List<PrescriptionResponse>>> getPrescriptionsByPatientId(
    int patientId,
    String token,
  );

  Future<Either<Error, List<PrescriptionResponse>>> getPrescriptionsByRecordId(
    int recordId,
    String token,
  );

  Future<Either<Error, List<PrescriptionDetails>>> getPrescriptionDetails(
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

  Future<Either<Error, dynamic>> updatePrescriptionMedication(
    int prescriptionId,
    int medId,
    Map<String, dynamic> updates,
    String token,
  );

  Future<Either<Error, dynamic>> deletePrescriptionMedication(
    int prescriptionId,
    int medId,
    String token,
  );

  Future<Either<Error, dynamic>> addPrescriptionMedication(
    int prescriptionId,
    List<Map<String, dynamic>> medData,
    String token,
  );
}
