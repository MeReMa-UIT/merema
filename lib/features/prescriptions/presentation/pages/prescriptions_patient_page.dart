import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/features/prescriptions/presentation/bloc/prescriptions_state_cubit.dart';
import 'package:merema/features/prescriptions/presentation/bloc/prescriptions_state.dart';
import 'package:merema/features/prescriptions/presentation/bloc/medications_state_cubit.dart';
import 'package:merema/features/profile/presentation/bloc/profile_state_cubit.dart';
import 'package:merema/features/profile/presentation/bloc/profile_state.dart';
import 'package:merema/core/layers/presentation/widgets/custom_dropdown.dart';
import 'package:merema/features/prescriptions/presentation/widgets/prescription_card.dart';
import 'package:merema/features/prescriptions/presentation/widgets/prescription_details_dialog.dart';

class PrescriptionsPatientPage extends StatefulWidget {
  const PrescriptionsPatientPage({super.key});

  static Route route() => MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => PrescriptionsCubit()),
            BlocProvider(create: (_) => MedicationsCubit()),
            BlocProvider(create: (_) => ProfileCubit()..getProfile()),
          ],
          child: const PrescriptionsPatientPage(),
        ),
      );

  @override
  State<PrescriptionsPatientPage> createState() =>
      _PrescriptionsPatientPageState();
}

class _PrescriptionsPatientPageState extends State<PrescriptionsPatientPage> {
  String? selectedPatientId;
  String? selectedPatientName;
  PrescriptionsState? _storedPrescriptionsState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Prescriptions'),
        backgroundColor: AppPallete.backgroundColor,
        foregroundColor: AppPallete.textColor,
      ),
      backgroundColor: AppPallete.backgroundColor,
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, profileState) {
          if (profileState is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (profileState is ProfileLoaded) {
            return _buildContent(profileState);
          } else if (profileState is ProfileError) {
            return Center(
              child: Text(
                profileState.message,
                style: const TextStyle(color: AppPallete.errorColor),
                textAlign: TextAlign.center,
              ),
            );
          }
          return const Center(child: Text('No profile data'));
        },
      ),
    );
  }

  Widget _buildContent(ProfileLoaded profileState) {
    final profile = profileState.profile;
    final info = profile.info;
    final patientsInfos = info['patients_infos'] as List? ?? [];

    if (patientsInfos.isEmpty) {
      return const Center(
        child: Text(
          'No patient information available',
          style: TextStyle(color: AppPallete.textColor),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildPatientDropdown(patientsInfos),
              const SizedBox(height: 16),
              if (selectedPatientId != null) _buildPrescriptionsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientDropdown(List patientsInfos) {
    return Card(
      color: AppPallete.backgroundColor,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.person_search, color: AppPallete.textColor),
                SizedBox(width: 8),
                Text(
                  'Select Patient',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppPallete.textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomDropdown<dynamic>(
              selectedValue: null,
              availableItems: patientsInfos,
              onChanged: (patient) {
                if (patient != null) {
                  setState(() {
                    selectedPatientId = patient['patient_id'];
                    selectedPatientName = patient['full_name'];
                  });
                  context.read<PrescriptionsCubit>().getPrescriptionsByPatient(
                      int.parse(patient['patient_id']));
                }
              },
              getDisplayText: (patient) => patient['full_name'],
              labelText: 'Select Patient',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionsList() {
    return BlocBuilder<PrescriptionsCubit, PrescriptionsState>(
      builder: (context, state) {
        if (state is PrescriptionsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PrescriptionsLoaded) {
          final prescriptions = state.prescriptions;

          if (prescriptions.isEmpty) {
            return Center(
              child: Text(
                'No prescriptions found for $selectedPatientName',
                style: const TextStyle(
                  color: AppPallete.textColor,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }

          return Column(
            children: prescriptions.map((prescription) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: PrescriptionCard(
                  prescription: prescription,
                  onViewDetails: () =>
                      _showPrescriptionDetails(prescription.prescriptionId),
                ),
              );
            }).toList(),
          );
        } else if (state is PrescriptionsError) {
          return Center(
            child: Text(
              'Error: ${state.message}',
              style: const TextStyle(
                color: AppPallete.errorColor,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showPrescriptionDetails(int prescriptionId) {
    final currentState = context.read<PrescriptionsCubit>().state;
    if (currentState is PrescriptionsLoaded) {
      _storedPrescriptionsState = currentState;
    }

    context.read<PrescriptionsCubit>().getPrescriptionDetails(prescriptionId);

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<PrescriptionsCubit>(),
        child: BlocProvider.value(
          value: context.read<MedicationsCubit>(),
          child: Dialog(
            backgroundColor: AppPallete.backgroundColor,
            child: Container(
              width: 600,
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(16),
              child: BlocBuilder<PrescriptionsCubit, PrescriptionsState>(
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
              ),
            ),
          ),
        ),
      ),
    ).then((_) {
      if (_storedPrescriptionsState != null && mounted) {
        context
            .read<PrescriptionsCubit>()
            .restorePrescriptionsState(_storedPrescriptionsState!);
      }
    });
  }
}
