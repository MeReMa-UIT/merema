import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/features/records/presentation/bloc/records_state_cubit.dart';
import 'package:merema/features/profile/presentation/bloc/profile_state_cubit.dart';
import 'package:merema/features/profile/presentation/bloc/profile_state.dart';
import 'package:merema/core/layers/presentation/widgets/custom_dropdown.dart';
import 'package:merema/features/records/presentation/widgets/record_list_view.dart';

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
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: RecordListView(
        patientId:
            selectedPatientId != null ? int.parse(selectedPatientId!) : null,
        emptyMessage: 'No medical records found for $selectedPatientName',
      ),
    );
  }
}
