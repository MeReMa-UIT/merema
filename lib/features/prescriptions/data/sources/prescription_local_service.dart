import 'dart:convert';
import 'package:merema/features/prescriptions/data/models/medications_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class PrescriptionLocalService {
  Future<MedicationsModel?> getCachedMedications();
  Future<void> cacheMedications(MedicationsModel medications);
}

class PrescriptionLocalServiceImpl implements PrescriptionLocalService {
  static const String CACHED_MEDICATIONS = 'CACHED_MEDICATIONS';

  @override
  Future<MedicationsModel?> getCachedMedications() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final jsonString = sharedPreferences.getString(CACHED_MEDICATIONS);
    return jsonString != null
        ? MedicationsModel.fromJson(json.decode(jsonString))
        : null;
  }

  @override
  Future<void> cacheMedications(MedicationsModel medications) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(
      CACHED_MEDICATIONS,
      json.encode(medications.toJson()),
    );
  }
}
