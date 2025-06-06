import 'package:equatable/equatable.dart';
import 'package:merema/features/prescriptions/domain/entities/medications.dart';

abstract class MedicationsState extends Equatable {
  const MedicationsState();

  @override
  List<Object?> get props => [];
}

class MedicationsInitial extends MedicationsState {}

class MedicationsLoaded extends MedicationsState {
  final List<Medication> medications;

  const MedicationsLoaded(this.medications);

  @override
  List<Object?> get props => [medications];
}

class MedicationLoaded extends MedicationsState {
  final Medication medication;

  const MedicationLoaded(this.medication);

  @override
  List<Object?> get props => [medication];
}

class MedicationError extends MedicationsState {
  final String message;

  const MedicationError(this.message);

  @override
  List<Object?> get props => [message];
}
