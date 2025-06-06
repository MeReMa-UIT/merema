import 'package:equatable/equatable.dart';
import 'package:merema/features/prescriptions/domain/entities/prescription.dart';

abstract class PrescriptionsState extends Equatable {
  const PrescriptionsState();

  @override
  List<Object?> get props => [];
}

class PrescriptionsInitial extends PrescriptionsState {}

class PrescriptionsLoading extends PrescriptionsState {}

class PrescriptionsLoaded extends PrescriptionsState {
  final List<PrescriptionResponse> prescriptions;

  const PrescriptionsLoaded(this.prescriptions);

  @override
  List<Object?> get props => [prescriptions];
}

class PrescriptionDetailsLoading extends PrescriptionsState {}

class PrescriptionDetailsLoaded extends PrescriptionsState {
  final List<PrescriptionDetails> details;

  const PrescriptionDetailsLoaded(this.details);

  @override
  List<Object?> get props => [details];
}

class PrescriptionsError extends PrescriptionsState {
  final String message;

  const PrescriptionsError(this.message);

  @override
  List<Object?> get props => [message];
}
