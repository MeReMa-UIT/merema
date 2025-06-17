import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/features/records/presentation/bloc/records_state_cubit.dart';
import 'package:merema/features/records/presentation/bloc/records_state.dart';
import 'package:merema/features/records/presentation/widgets/record_card.dart';
import 'package:merema/features/records/presentation/widgets/record_details_dialog.dart';
import 'package:merema/features/profile/presentation/bloc/profile_state_cubit.dart';
import 'package:merema/features/profile/presentation/bloc/profile_state.dart';
import 'package:merema/core/layers/presentation/widgets/custom_dropdown.dart';

class RecordsPatientPage extends StatefulWidget {
  const RecordsPatientPage({super.key});

  static Route route() => MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => RecordsCubit()),
            BlocProvider(create: (_) => ProfileCubit()..getProfile()),
          ],
          child: const RecordsPatientPage(),
        ),
      );

  @override
  State<RecordsPatientPage> createState() => _RecordsPatientPageState();
}

class _RecordsPatientPageState extends State<RecordsPatientPage> {
  String? selectedPatientId;
  String? selectedPatientName;
  RecordsState? _storedRecordsState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecordsCubit>().getAllRecords();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Medical Records'),
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
              if (selectedPatientId != null) _buildRecordsList(),
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
                  context
                      .read<RecordsCubit>()
                      .getRecordsByPatient(int.parse(patient['patient_id']));
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

  Widget _buildRecordsList() {
    return BlocBuilder<RecordsCubit, RecordsState>(
      builder: (context, state) {
        if (state is RecordsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is RecordsLoaded) {
          final records = state.filteredRecords;

          if (records.isEmpty) {
            return Center(
              child: Text(
                'No medical records found for $selectedPatientName',
                style: const TextStyle(
                  color: AppPallete.textColor,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }

          return Column(
            children: records.map((record) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: RecordCard(
                  record: record,
                  onViewDetails: () => _showRecordDetails(record.recordId),
                ),
              );
            }).toList(),
          );
        } else if (state is RecordsError) {
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

  void _showRecordDetails(int recordId) {
    final currentState = context.read<RecordsCubit>().state;
    if (currentState is RecordsLoaded) {
      _storedRecordsState = currentState;
    }

    context.read<RecordsCubit>().getRecordDetails(recordId);

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<RecordsCubit>(),
        child: Dialog(
          backgroundColor: AppPallete.backgroundColor,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.95,
            padding: const EdgeInsets.all(16),
            child: BlocBuilder<RecordsCubit, RecordsState>(
              builder: (context, state) {
                if (state is RecordDetailsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is RecordDetailsLoaded) {
                  return RecordDetailsDialog(
                    recordDetail: state.recordDetail,
                    onRecordUpdated: () {
                      if (selectedPatientId != null) {
                        context.read<RecordsCubit>().getRecordsByPatient(int.parse(selectedPatientId!));
                      }
                    },
                  );
                } else if (state is RecordsError) {
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
    ).then((_) {
      if (_storedRecordsState != null && mounted) {
        context.read<RecordsCubit>().restoreRecordsState(_storedRecordsState!);
      }
    });
  }
}
