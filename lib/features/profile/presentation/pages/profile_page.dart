import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/features/profile/presentation/bloc/profile_state_cubit.dart';
import 'package:merema/features/profile/presentation/bloc/profile_state.dart';
import 'package:merema/features/profile/presentation/widgets/info_card.dart';

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
                    title: 'Personal Information',
                    fields: [
                      InfoField(
                          label: 'Full Name',
                          value: profile.info['full_name']),
                      InfoField(label: 'Citizen ID', value: profile.citizenId),
                      InfoField(
                          label: 'Date of Birth',
                          value: profile.info['date_of_birth']),
                      InfoField(
                          label: 'Gender', value: profile.info['gender']),
                      InfoField(
                          label: 'Role', value: profile.role),
                      if (profile.role == 'patient')
                        InfoField(
                            label: 'Patient ID',
                            value: profile.info['patient_id'])
                      else ...[
                        InfoField(
                            label: 'Staff ID',
                            value: profile.info['staff_id']),
                        InfoField(
                            label: 'Department',
                            value: profile.info['department']),
                      ],
                      InfoField(label: 'Email', value: profile.email),
                      InfoField(label: 'Phone Number', value: profile.phone),
                    ],
                  ),
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
}
