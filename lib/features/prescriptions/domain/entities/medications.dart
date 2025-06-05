import 'package:equatable/equatable.dart';

class Medication extends Equatable {
  final String genericName;
  final String manufacturer;
  final int medId;
  final String medType;
  final String name;
  final String routeOfAdministration;
  final String strength;

  const Medication({
    required this.genericName,
    required this.manufacturer,
    required this.medId,
    required this.medType,
    required this.name,
    required this.routeOfAdministration,
    required this.strength,
  });

  @override
  List<Object?> get props => [
        genericName,
        manufacturer,
        medId,
        medType,
        name,
        routeOfAdministration,
        strength,
      ];
}

class Medications extends Equatable {
  final List<Medication> medications;

  const Medications({
    required this.medications,
  });

  @override
  List<Object?> get props => [medications];
}
