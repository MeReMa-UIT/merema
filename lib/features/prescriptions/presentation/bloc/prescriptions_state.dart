abstract class PrescriptionsState {}

class PrescriptionsInitial extends PrescriptionsState {}

class PrescriptionsLoading extends PrescriptionsState {}

class PrescriptionsLoaded extends PrescriptionsState {
  final List<dynamic> prescriptions;
  final Map<int, String> medications;

  PrescriptionsLoaded({
    required this.prescriptions,
    this.medications = const {},
  });
}

class PrescriptionsError extends PrescriptionsState {
  final String message;

  PrescriptionsError({required this.message});
}
