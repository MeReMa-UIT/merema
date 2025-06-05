import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/layers/domain/entities/user_role.dart';
import 'package:merema/core/layers/presentation/widgets/app_field.dart';
import 'package:merema/core/layers/presentation/widgets/app_button.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/features/patients/presentation/bloc/patients_state_cubit.dart';
import 'package:merema/features/patients/presentation/bloc/patients_state.dart';
import 'package:merema/features/patients/presentation/pages/patient_infos_page.dart';
import 'package:merema/features/patients/presentation/pages/patient_register_page.dart';

class PatientsPage extends StatefulWidget {
  const PatientsPage({super.key});

  static Route route() => MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => PatientsCubit()..getPatients(),
          child: const PatientsPage(),
        ),
      );

  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    context.read<PatientsCubit>().searchPatients(
          searchQuery: _searchController.text,
        );
  }

  void _onClear() {
    _searchController.clear();
    context.read<PatientsCubit>().clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients'),
        backgroundColor: AppPallete.backgroundColor,
        foregroundColor: AppPallete.textColor,
        actions: [
          BlocBuilder<PatientsCubit, PatientsState>(
            builder: (context, state) {
              if (state is PatientsLoaded &&
                  state.userRole == UserRole.receptionist) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: IconButton(
                    icon: const Icon(Icons.person_add),
                    tooltip: 'Register Patient',
                    onPressed: () {
                      Navigator.of(context).push(PatientRegisterPage.route());
                    },
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      backgroundColor: AppPallete.backgroundColor,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                AppField(
                  labelText: 'Search patients',
                  controller: _searchController,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: 'Clear',
                        onPressed: _onClear,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        text: 'Search',
                        onPressed: _onSearch,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<PatientsCubit, PatientsState>(
              builder: (context, state) {
                if (state is PatientsLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppPallete.primaryColor,
                    ),
                  );
                } else if (state is PatientsError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppPallete.errorColor,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style: const TextStyle(
                            color: AppPallete.errorColor,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: AppButton(
                            text: 'Retry',
                            onPressed: () =>
                                context.read<PatientsCubit>().getPatients(),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (state is PatientsLoaded) {
                  if (state.filteredPatients.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            color: AppPallete.lightGrayColor,
                            size: 64,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No patients found',
                            style: TextStyle(
                              color: AppPallete.darkGrayColor,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: state.filteredPatients.length,
                    itemBuilder: (context, index) {
                      final patient = state.filteredPatients[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        color: Colors.white,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppPallete.secondaryColor,
                            child: Text(
                              patient.fullName.isNotEmpty
                                  ? patient.fullName[0]
                                  : '',
                              style: const TextStyle(
                                color: AppPallete.textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            patient.fullName,
                            style: const TextStyle(
                              color: AppPallete.textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DOB: ${patient.dateOfBirth.split('T')[0]}',
                                style: const TextStyle(
                                  color: AppPallete.darkGrayColor,
                                ),
                              ),
                              Text(
                                'Gender: ${patient.gender}',
                                style: const TextStyle(
                                  color: AppPallete.darkGrayColor,
                                ),
                              ),
                            ],
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: AppPallete.lightGrayColor,
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              PatientInfosPage.route(patient.patientId),
                            );
                          },
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
