import 'package:merema/features/prescriptions/domain/entities/medications.dart';

class MedicationModel extends Medication {
  const MedicationModel({
    required super.genericName,
    required super.manufacturer,
    required super.medId,
    required super.medType,
    required super.name,
    required super.routeOfAdministration,
    required super.strength,
  });

  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    return MedicationModel(
      genericName: json['generic_name'],
      manufacturer: json['manufacturer'],
      medId: json['med_id'],
      medType: json['med_type'],
      name: json['name'],
      routeOfAdministration: json['route_of_administration'],
      strength: json['strength'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'generic_name': genericName,
      'manufacturer': manufacturer,
      'med_id': medId,
      'med_type': medType,
      'name': name,
      'route_of_administration': routeOfAdministration,
      'strength': strength,
    };
  }
}

class MedicationsModel extends Medications {
  const MedicationsModel({
    required super.medications,
  });

  factory MedicationsModel.fromJson(List<dynamic> json) {
    final medicationsList = json
        .map((medicationJson) => MedicationModel.fromJson(medicationJson))
        .toList();

    return MedicationsModel(
      medications: medicationsList,
    );
  }

  List<dynamic> toJson() {
    return medications
        .map((medication) => (medication as MedicationModel).toJson())
        .toList();
  }
}
