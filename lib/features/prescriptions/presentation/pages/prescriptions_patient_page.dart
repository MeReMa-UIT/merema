// TODO: I hope it works

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/core/layers/presentation/widgets/info_card.dart';
import 'package:merema/core/layers/presentation/widgets/custom_dropdown.dart';
import 'package:merema/features/profile/domain/usecases/get_user_profile.dart';
import 'package:merema/features/prescriptions/presentation/bloc/prescriptions_state_cubit.dart';
import 'package:merema/features/prescriptions/presentation/bloc/prescriptions_state.dart';

class PrescriptionsPage extends StatefulWidget {
  const PrescriptionsPage({super.key});

  static Route route() => MaterialPageRoute(
        builder: (context) => const PrescriptionsPage(),
      );

  @override
  State<PrescriptionsPage> createState() => _PrescriptionsPageState();
}

class _PrescriptionsPageState extends State<PrescriptionsPage> {
  Map<String, dynamic>? selectedPatient;
  List<dynamic> availablePatients = [];
  bool isLoadingProfile = true;
  PrescriptionsCubit? _prescriptionsCubit;
  int? _initialPatientId;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  void _loadPrescriptionsForPatient(int patientId) {
    _prescriptionsCubit?.getPrescriptionsByPatient(patientId);
  }

  Future<void> _loadPatients() async {
    try {
      final result = await sl<GetUserProfileUseCase>().call(null);
      result.fold(
        (error) {
          setState(() {
            isLoadingProfile = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error loading profile: $error')),
            );
          }
        },
        (userProfile) {
          if (userProfile.info.containsKey('patients_infos')) {
            final patientsInfos = userProfile.info['patients_infos'] as List;
            setState(() {
              availablePatients = patientsInfos;
              if (patientsInfos.isNotEmpty) {
                selectedPatient = patientsInfos.first;
              }
              isLoadingProfile = false;
            });
            if (patientsInfos.isNotEmpty) {
              _initialPatientId = int.parse(patientsInfos.first['patient_id']);
            }
          } else {
            setState(() {
              isLoadingProfile = false;
            });
          }
        },
      );
    } catch (e) {
      setState(() {
        isLoadingProfile = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading patients: $e')),
        );
      }
    }
  }

  Widget _buildPatientDropdown() {
    return CustomDropdown<Map<String, dynamic>>(
      selectedValue: selectedPatient,
      availableItems: availablePatients.cast<Map<String, dynamic>>(),
      labelText: 'Select Patient',
      getDisplayText: (patient) => patient['full_name'] ?? 'Unknown Patient',
      onChanged: (Map<String, dynamic>? newValue) {
        if (newValue != null) {
          setState(() {
            selectedPatient = newValue;
          });
          _loadPrescriptionsForPatient(int.parse(newValue['patient_id']));
        }
      },
    );
  }

  Widget _buildPrescriptionCard(
      dynamic prescription, int index, Map<int, String> medications) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InfoCard(
        title: 'Prescription #$index',
        icon: Icons.medication,
        fields: [
          InfoField(
              label: 'Record ID',
              value: prescription['recordId']?.toString() ?? ''),
          InfoField(
              label: 'Insurance Covered',
              value: prescription['isInsuranceCovered'] == true ? 'Yes' : 'No'),
          if (prescription['prescriptionNote'] != null &&
              prescription['prescriptionNote'].toString().isNotEmpty)
            InfoField(
                label: 'Prescription Note',
                value: prescription['prescriptionNote'].toString()),
          if (prescription['details'] != null &&
              prescription['details'] is List)
            ...((prescription['details'] as List)
                .asMap()
                .entries
                .map((entry) {
                  final detailIndex = entry.key + 1;
                  final detail = entry.value;
                  final medId = detail['medId'] as int?;
                  final medicineName = medId != null
                      ? medications[medId] ?? 'Unknown Medicine'
                      : 'Unknown Medicine';

                  return [
                    InfoField(
                        label: 'Medicine $detailIndex', value: medicineName),
                    InfoField(
                        label: 'Instructions $detailIndex',
                        value: detail['instructions']?.toString() ?? ''),
                    InfoField(
                        label: 'Morning Dosage $detailIndex',
                        value: detail['morningDosage']?.toString() ?? '0'),
                    InfoField(
                        label: 'Afternoon Dosage $detailIndex',
                        value: detail['afternoonDosage']?.toString() ?? '0'),
                    InfoField(
                        label: 'Evening Dosage $detailIndex',
                        value: detail['eveningDosage']?.toString() ?? '0'),
                    InfoField(
                        label: 'Total Dosage $detailIndex',
                        value: detail['totalDosage']?.toString() ?? '0'),
                    InfoField(
                        label: 'Dosage Unit $detailIndex',
                        value: detail['dosageUnit']?.toString() ?? ''),
                    InfoField(
                        label: 'Duration Days $detailIndex',
                        value: detail['durationDays']?.toString() ?? '0'),
                  ];
                })
                .expand((x) => x)
                .toList()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        _prescriptionsCubit = PrescriptionsCubit();
        if (_initialPatientId != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadPrescriptionsForPatient(_initialPatientId!);
          });
        }
        return _prescriptionsCubit!;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Prescriptions'),
          backgroundColor: AppPallete.backgroundColor,
          foregroundColor: AppPallete.textColor,
        ),
        backgroundColor: AppPallete.backgroundColor,
        body: isLoadingProfile
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppPallete.primaryColor,
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Column(
                  children: [
                    if (availablePatients.length > 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: _buildPatientDropdown(),
                      ),
                    Expanded(
                      child:
                          BlocBuilder<PrescriptionsCubit, PrescriptionsState>(
                        builder: (context, state) {
                          if (state is PrescriptionsLoading) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppPallete.primaryColor,
                              ),
                            );
                          }

                          if (state is PrescriptionsError) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    size: 64,
                                    color: AppPallete.errorColor,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    state.message,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: AppPallete.errorColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }

                          if (state is PrescriptionsLoaded) {
                            final prescriptions = state.prescriptions;
                            final medications = state.medications;

                            if (prescriptions.isEmpty) {
                              return const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.medication_outlined,
                                      size: 64,
                                      color: AppPallete.textColor,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'No prescriptions found',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: AppPallete.textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return SingleChildScrollView(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (int index = 0;
                                      index < prescriptions.length;
                                      index++)
                                    _buildPrescriptionCard(prescriptions[index],
                                        index + 1, medications),
                                ],
                              ),
                            );
                          }

                          return const Center(
                            child:
                                Text('No prescription information available'),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
