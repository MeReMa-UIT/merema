import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/core/layers/presentation/widgets/info_card.dart';
import 'package:merema/features/staffs/presentation/bloc/staff_infos_state.dart';
import 'package:merema/features/staffs/presentation/bloc/staff_infos_state_cubit.dart';
import 'package:merema/features/staffs/presentation/pages/staff_update_infos_page.dart';

class StaffInfosPage extends StatelessWidget {
  final int staffId;

  const StaffInfosPage({
    super.key,
    required this.staffId,
  });

  static Route<void> route(int staffId) {
    return MaterialPageRoute<void>(
      builder: (_) => StaffInfosPage(staffId: staffId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StaffInfosCubit()..getInfos(staffId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Staff Information'),
          backgroundColor: AppPallete.backgroundColor,
          foregroundColor: AppPallete.textColor,
          actions: [
            BlocBuilder<StaffInfosCubit, StaffInfosState>(
              builder: (context, state) {
                if (state is StaffInfosLoaded) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: IconButton(
                      icon: const Icon(Icons.edit,
                          color: AppPallete.primaryColor),
                      tooltip: 'Update Info',
                      onPressed: () {
                        Navigator.of(context).push(
                          StaffUpdateInfosPage.route(staffId, state.staffInfo),
                        );
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
        body: BlocBuilder<StaffInfosCubit, StaffInfosState>(
          builder: (context, state) {
            if (state is StaffInfosLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppPallete.primaryColor,
                ),
              );
            }

            if (state is StaffInfosError) {
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

            if (state is StaffInfosLoaded) {
              final staff = state.staffInfo;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InfoCard(
                      title: 'Personal Information',
                      icon: Icons.person,
                      fields: [
                        InfoField(label: 'Full Name', value: staff.fullName),
                        InfoField(
                            label: 'Date of Birth', value: staff.dateOfBirth),
                        InfoField(label: 'Gender', value: staff.gender),
                      ],
                    ),
                    const SizedBox(height: 16),
                    InfoCard(
                      title: 'Work Information',
                      icon: Icons.work,
                      fields: [
                        InfoField(label: 'Department', value: staff.department),
                        InfoField(
                            label: 'Staff ID', value: staff.staffId.toString()),
                      ],
                    ),
                  ],
                ),
              );
            }

            return const Center(
              child: Text('No staff information available'),
            );
          },
        ),
      ),
    );
  }
}
