// TODO: Add patient and staff more infos /patients/{patient_id}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/features/profile/presentation/bloc/profile_state_cubit.dart';
import 'package:merema/features/profile/presentation/bloc/profile_state.dart';
import 'package:merema/core/layers/presentation/widgets/info_card.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static Route route() => MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (_) => ProfileCubit()..getProfile(),
          child: const ProfilePage(),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoaded) {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // TODO: Navigate to update profile page
                  },
                );
              }
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => context.read<ProfileCubit>().getProfile(),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProfileLoaded) {
            final profile = state.profile;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoCard(
                    title: 'Account Information',
                    icon: Icons.account_circle,
                    fields: [
                      InfoField(label: 'Citizen ID', value: profile.citizenId),
                      InfoField(label: 'Email', value: profile.email),
                      InfoField(label: 'Phone Number', value: profile.phone),
                      InfoField(label: 'Role', value: profile.role),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (profile.role == 'patient')
                    _buildPatientInfo(profile)
                  else if (profile.role != 'admin')
                    _buildStaffInfo(profile),
                ],
              ),
            );
          } else if (state is ProfileError) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Failed to load profile',
                    style: TextStyle(color: AppPallete.errorColor),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('No profile data'));
        },
      ),
    );
  }

  Widget _buildPatientInfo(profile) {
    final info = profile.info;

    if (info.containsKey('patients_infos')) {
      final patientsInfos = info['patients_infos'] as List;
      return Column(
        children: patientsInfos.map<Widget>((patientInfo) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: InfoCard(
              title: 'Patient Information - ${patientInfo['full_name']}',
              icon: Icons.person,
              fields: [
                InfoField(label: 'Full Name', value: patientInfo['full_name']),
                InfoField(
                    label: 'Date of Birth',
                    value: patientInfo['date_of_birth']),
                InfoField(label: 'Gender', value: patientInfo['gender']),
                InfoField(
                    label: 'Patient ID', value: patientInfo['patient_id']),
              ],
            ),
          );
        }).toList(),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildStaffInfo(profile) {
    final info = profile.info;
    return InfoCard(
      title: 'Staff Information',
      icon: Icons.badge,
      fields: [
        InfoField(label: 'Full Name', value: info['full_name']),
        InfoField(label: 'Date of Birth', value: info['date_of_birth']),
        InfoField(label: 'Gender', value: info['gender']),
        InfoField(label: 'Staff ID', value: info['staff_id']),
        InfoField(label: 'Department', value: info['department']),
      ],
    );
  }
}
