import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/layers/presentation/widgets/app_field.dart';
import 'package:merema/core/layers/presentation/widgets/app_button.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/features/staffs/presentation/bloc/staffs_state_cubit.dart';
import 'package:merema/features/staffs/presentation/bloc/staffs_state.dart';
import 'package:merema/features/staffs/presentation/pages/staff_infos_page.dart';
import 'package:merema/features/staffs/presentation/pages/staff_register_page.dart';

class StaffsPage extends StatefulWidget {
  const StaffsPage({super.key});

  static Route route() => MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => StaffsCubit()..getStaffs(),
          child: const StaffsPage(),
        ),
      );

  @override
  State<StaffsPage> createState() => _StaffsPageState();
}

class _StaffsPageState extends State<StaffsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    context.read<StaffsCubit>().searchStaffs(
          searchQuery: _searchController.text,
        );
  }

  void _onClear() {
    _searchController.clear();
    context.read<StaffsCubit>().clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staffs'),
        backgroundColor: AppPallete.backgroundColor,
        foregroundColor: AppPallete.textColor,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              icon: const Icon(Icons.person_add),
              tooltip: 'Register Staff',
              onPressed: () {
                Navigator.of(context).push(StaffRegisterPage.route());
              },
            ),
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
                  labelText: 'Search staffs',
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
            child: BlocBuilder<StaffsCubit, StaffsState>(
              builder: (context, state) {
                if (state is StaffsLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppPallete.primaryColor,
                    ),
                  );
                } else if (state is StaffsError) {
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
                                context.read<StaffsCubit>().getStaffs(),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (state is StaffsLoaded) {
                  if (state.filteredStaffs.isEmpty) {
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
                            'No staffs found',
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
                    itemCount: state.filteredStaffs.length,
                    itemBuilder: (context, index) {
                      final staff = state.filteredStaffs[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        color: Colors.white,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppPallete.secondaryColor,
                            child: Text(
                              staff.fullName.isNotEmpty
                                  ? staff.fullName[0]
                                  : '',
                              style: const TextStyle(
                                color: AppPallete.textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            staff.fullName,
                            style: const TextStyle(
                              color: AppPallete.textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Department: ${staff.department}',
                                style: const TextStyle(
                                  color: AppPallete.darkGrayColor,
                                ),
                              ),
                              Text(
                                'DOB: ${staff.dateOfBirth.split('T')[0]}',
                                style: const TextStyle(
                                  color: AppPallete.darkGrayColor,
                                ),
                              ),
                              Text(
                                'Gender: ${staff.gender}',
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
                              StaffInfosPage.route(staff.staffId),
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
