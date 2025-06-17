import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/features/prescriptions/presentation/bloc/prescriptions_state_cubit.dart';
import 'package:merema/features/prescriptions/presentation/bloc/prescriptions_state.dart';
import 'package:merema/features/prescriptions/presentation/widgets/prescription_card.dart';
import 'package:merema/features/prescriptions/presentation/widgets/prescription_details_dialog.dart';
import 'package:merema/features/prescriptions/presentation/widgets/prescription_create_dialog.dart';
import 'package:merema/features/prescriptions/presentation/widgets/prescription_update_dialog.dart';
import 'package:merema/features/prescriptions/presentation/bloc/medications_state_cubit.dart';
import 'package:merema/features/prescriptions/domain/usecases/confirm_received.dart';
import 'package:merema/core/services/service_locator.dart';

class PrescriptionListView extends StatefulWidget {
  final int? recordId;
  final int? patientId;
  final String? emptyMessage;
  final bool showCreateButton;
  final bool isFromDoctorPage;
  final VoidCallback? onPrescriptionCreated;
  final VoidCallback? onSwitchToPrescriptionsTab;
  final PrescriptionsCubit? prescriptionsCubit;

  const PrescriptionListView({
    super.key,
    this.recordId,
    this.patientId,
    this.emptyMessage,
    this.showCreateButton = false,
    this.isFromDoctorPage = false,
    this.onPrescriptionCreated,
    this.onSwitchToPrescriptionsTab,
    this.prescriptionsCubit,
  });

  @override
  State<PrescriptionListView> createState() => _PrescriptionListViewState();
}

class _PrescriptionListViewState extends State<PrescriptionListView> {
  bool _hasInitialized = false;

  PrescriptionsCubit get _cubit {
    return widget.prescriptionsCubit ?? context.read<PrescriptionsCubit>();
  }

  @override
  void initState() {
    super.initState();
    if (widget.recordId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_hasInitialized) {
          _hasInitialized = true;
          _cubit.getPrescriptionsByRecord(widget.recordId!);
        }
      });
    }
  }

  @override
  void didUpdateWidget(PrescriptionListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.recordId != widget.recordId && widget.recordId != null) {
      _cubit.getPrescriptionsByRecord(widget.recordId!);
    }
  }

  void _handleViewDetails(int prescriptionId) {
    showDialog(
      context: context,
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => PrescriptionsCubit()),
          BlocProvider(create: (_) => MedicationsCubit()),
        ],
        child: Dialog(
          backgroundColor: AppPallete.backgroundColor,
          child: Container(
            width: 600,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(16),
            child: Builder(
              builder: (context) {
                context
                    .read<PrescriptionsCubit>()
                    .getPrescriptionDetails(prescriptionId);

                return BlocBuilder<PrescriptionsCubit, PrescriptionsState>(
                  builder: (context, state) {
                    if (state is PrescriptionDetailsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is PrescriptionDetailsLoaded) {
                      return PrescriptionDetailsDialog(
                          prescriptionDetails: state.details);
                    } else if (state is PrescriptionsError) {
                      return Center(
                        child: Text(
                          'Error loading details: ${state.message}',
                          style: const TextStyle(color: AppPallete.errorColor),
                        ),
                      );
                    }
                    return const Center(child: Text('Loading...'));
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _handleCreatePrescription() {
    if (widget.recordId == null) return;

    showDialog(
      context: context,
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => MedicationsCubit()),
        ],
        child: Dialog(
          backgroundColor: AppPallete.backgroundColor,
          child: Container(
            width: 600,
            height: MediaQuery.of(context).size.height * 0.85,
            padding: const EdgeInsets.all(16),
            child: PrescriptionCreateDialog(
              recordId: widget.recordId!,
              onCancel: () => Navigator.of(dialogContext).pop(),
              onSuccess: () {
                Navigator.of(dialogContext).pop();
                if (widget.recordId != null) {
                  _cubit.getPrescriptionsByRecord(widget.recordId!);
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  void _handleUpdatePrescription(int prescriptionId) async {
    final prescriptionsState = _cubit.state;
    if (prescriptionsState is! PrescriptionsLoaded) return;

    final prescriptions = prescriptionsState.prescriptions;
    final prescription = prescriptions.firstWhere(
      (p) => p.prescriptionId == prescriptionId,
      orElse: () => throw Exception('Prescription not found'),
    );

    showDialog(
      context: context,
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => PrescriptionsCubit()),
          BlocProvider(create: (_) => MedicationsCubit()),
        ],
        child: Dialog(
          backgroundColor: AppPallete.backgroundColor,
          child: Container(
            width: 600,
            height: MediaQuery.of(context).size.height * 0.85,
            padding: const EdgeInsets.all(16),
            child: Builder(
              builder: (context) {
                context
                    .read<PrescriptionsCubit>()
                    .getPrescriptionDetails(prescriptionId);

                return BlocBuilder<PrescriptionsCubit, PrescriptionsState>(
                  builder: (context, state) {
                    if (state is PrescriptionDetailsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is PrescriptionDetailsLoaded) {
                      return PrescriptionUpdateDialog(
                        prescriptionId: prescriptionId,
                        prescriptionDetails: state.details,
                        isInsuranceCovered: prescription.isInsuranceCovered,
                        prescriptionNote: prescription.prescriptionNote,
                        onCancel: () => Navigator.of(dialogContext).pop(),
                        onSuccess: () {
                          Navigator.of(dialogContext).pop();
                          if (widget.recordId != null) {
                            _cubit.getPrescriptionsByRecord(widget.recordId!);
                          }
                        },
                      );
                    } else if (state is PrescriptionsError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: AppPallete.errorColor),
                        ),
                      );
                    }
                    return const Center(child: Text('Loading...'));
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _handleConfirmReceived(int prescriptionId) async {
    try {
      final confirmReceivedUseCase = sl<ConfirmReceivedUseCase>();
      final result = await confirmReceivedUseCase(prescriptionId);

      if (!mounted) return;

      result.fold(
        (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
            ),
          );
        },
        (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Prescription confirmed as received'),
            ),
          );

          if (widget.recordId != null) {
            _cubit.getPrescriptionsByRecord(widget.recordId!);
          }
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = _cubit;
    return BlocBuilder<PrescriptionsCubit, PrescriptionsState>(
      bloc: cubit,
      builder: (context, state) {
        if (state is PrescriptionsLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppPallete.primaryColor,
            ),
          );
        } else if (state is PrescriptionsLoaded) {
          final prescriptions = state.prescriptions;

          if (prescriptions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.medical_services_outlined,
                    size: 64,
                    color: AppPallete.lightGrayColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.emptyMessage ?? 'No prescriptions found',
                    style: const TextStyle(
                      color: AppPallete.textColor,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (widget.showCreateButton &&
                      widget.isFromDoctorPage &&
                      widget.recordId != null) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _handleCreatePrescription,
                      icon: const Icon(Icons.add),
                      label: const Text('Create Prescription'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPallete.primaryColor,
                        foregroundColor: AppPallete.backgroundColor,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Prescriptions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppPallete.textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: prescriptions.length,
                  itemBuilder: (context, index) {
                    final prescription = prescriptions[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: PrescriptionCard(
                        prescription: prescription,
                        isDoctor: widget.isFromDoctorPage,
                        onViewDetails: () =>
                            _handleViewDetails(prescription.prescriptionId),
                        onUpdatePrescription: widget.isFromDoctorPage
                            ? () => _handleUpdatePrescription(
                                prescription.prescriptionId)
                            : null,
                        onConfirmReceived: widget.isFromDoctorPage
                            ? () => _handleConfirmReceived(
                                prescription.prescriptionId)
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        } else if (state is PrescriptionsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.medical_services_outlined,
                  size: 64,
                  color: AppPallete.lightGrayColor,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.emptyMessage ?? 'No prescriptions found',
                  style: const TextStyle(
                    color: AppPallete.textColor,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (widget.recordId != null) {
                          _cubit.getPrescriptionsByRecord(widget.recordId!);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPallete.primaryColor,
                        foregroundColor: AppPallete.textColor,
                      ),
                      child: const Text('Retry'),
                    ),
                    if (widget.showCreateButton &&
                        widget.isFromDoctorPage &&
                        widget.recordId != null) ...[
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _handleCreatePrescription,
                        icon: const Icon(Icons.add),
                        label: const Text('Create Prescription'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppPallete.primaryColor,
                          foregroundColor: AppPallete.textColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          );
        }

        return const Center(
          child: Text(
            'No data available',
            style: TextStyle(
              color: AppPallete.textColor,
              fontSize: 16,
            ),
          ),
        );
      },
    );
  }
}
