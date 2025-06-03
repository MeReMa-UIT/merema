import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/core/layers/presentation/widgets/info_card.dart';
import 'package:merema/features/patients/presentation/bloc/patient_infos_state.dart';
import 'package:merema/features/patients/presentation/bloc/patient_infos_state_cubit.dart';

class PatientInfosPage extends StatelessWidget {
  final int patientId;

  const PatientInfosPage({
    super.key,
    required this.patientId,
  });

  static Route<void> route(int patientId) {
    return MaterialPageRoute<void>(
      builder: (_) => PatientInfosPage(patientId: patientId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PatientInfosCubit()..getInfos(patientId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Patient Information'),
          backgroundColor: AppPallete.backgroundColor,
          foregroundColor: AppPallete.textColor,
        ),
        backgroundColor: AppPallete.backgroundColor,
        body: BlocBuilder<PatientInfosCubit, PatientInfosState>(
          builder: (context, state) {
            if (state is PatientInfosLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppPallete.primaryColor,
                ),
              );
            }

            if (state is PatientInfosError) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppPallete.errorColor,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Failed to load patient information',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppPallete.errorColor,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is PatientInfosLoaded) {
              final patient = state.patientInfo;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InfoCard(
                      title: 'Personal Information',
                      icon: Icons.person,
                      fields: [
                        InfoField(label: 'Full Name', value: patient.fullName),
                        InfoField(
                            label: 'Date of Birth', value: patient.dateOfBirth),
                        InfoField(label: 'Gender', value: patient.gender),
                      ],
                    ),
                    const SizedBox(height: 16),
                    InfoCard(
                      title: 'Contact Information',
                      icon: Icons.contact_phone,
                      fields: [
                        InfoField(label: 'Address', value: patient.address),
                        InfoField(
                            label: 'Emergency Contact',
                            value: patient.emergencyContactInfo),
                      ],
                    ),
                    const SizedBox(height: 16),
                    InfoCard(
                      title: 'Background Information',
                      icon: Icons.public,
                      fields: [
                        InfoField(
                            label: 'Nationality', value: patient.nationality),
                        InfoField(label: 'Ethnicity', value: patient.ethnicity),
                      ],
                    ),
                    const SizedBox(height: 16),
                    InfoCard(
                      title: 'Health Insurance',
                      icon: Icons.health_and_safety,
                      fields: [
                        InfoField(
                            label: 'Insurance Number',
                            value: patient.healthInsuranceNumber),
                        InfoField(
                            label: 'Expiry Date',
                            value: patient.healthInsuranceExpiredDate),
                      ],
                    ),
                  ],
                ),
              );
            }

            return const Center(
              child: Text('No patient information available'),
            );
          },
        ),
      ),
    );
  }
}
