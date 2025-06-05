import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/layers/domain/entities/user_role.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/features/auth/domain/usecases/get_user_role.dart';
import 'package:merema/features/schedules/presentation/bloc/schedules_state_cubit.dart';
import 'package:merema/features/schedules/presentation/bloc/schedules_state.dart';
import 'package:merema/features/schedules/presentation/widgets/book_schedule_dialog.dart';
import 'package:merema/features/schedules/presentation/widgets/schedule_card.dart';
import 'package:merema/features/schedules/presentation/widgets/filter_section.dart';

class SchedulesPage extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (_) => SchedulesCubit()..getSchedules(),
          child: const SchedulesPage(),
        ),
      );

  const SchedulesPage({super.key});

  @override
  State<SchedulesPage> createState() => _SchedulesPageState();
}

class _SchedulesPageState extends State<SchedulesPage> {
  UserRole userRole = UserRole.noRole;
  List<int> selectedTypes = [];
  List<int> selectedStatuses = [];
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserRole() async {
    final role = await sl<GetUserRoleUseCase>().call(null);
    setState(() {
      userRole = role;
    });
  }

  void _toggleTypeFilter(int type) {
    setState(() {
      if (selectedTypes.contains(type)) {
        selectedTypes.remove(type);
      } else {
        selectedTypes.add(type);
      }
    });
    _applyFilters();
  }

  void _toggleStatusFilter(int status) {
    setState(() {
      if (selectedStatuses.contains(status)) {
        selectedStatuses.remove(status);
      } else {
        selectedStatuses.add(status);
      }
    });
    _applyFilters();
  }

  void _applyFilters() {
    context.read<SchedulesCubit>().getSchedules(
          types: selectedTypes.isEmpty ? null : selectedTypes,
          statuses: selectedStatuses.isEmpty ? null : selectedStatuses,
        );
  }

  void _showBookScheduleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BookScheduleDialog(
        onScheduleBooked: () {
          context.read<SchedulesCubit>().getSchedules();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedules'),
        actions: [
          if (userRole == UserRole.patient)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: IconButton(
                onPressed: () => _showBookScheduleDialog(context),
                icon: const Icon(Icons.add),
                tooltip: 'Book Schedule',
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          FilterSection(
            userRole: userRole,
            searchController: _searchController,
            searchQuery: searchQuery,
            selectedTypes: selectedTypes,
            selectedStatuses: selectedStatuses,
            onSearchChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            onTypeToggle: _toggleTypeFilter,
            onStatusToggle: _toggleStatusFilter,
          ),
          Container(
            height: 1,
            width: double.infinity,
            color: AppPallete.lightGrayColor,
          ),
          Expanded(
            child: BlocBuilder<SchedulesCubit, SchedulesState>(
              builder: (context, state) {
                if (state is SchedulesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is SchedulesError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error: ${state.message}',
                          style: const TextStyle(color: AppPallete.errorColor),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              context.read<SchedulesCubit>().getSchedules(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is SchedulesLoaded) {
                  List schedules = state.schedules;
                  if (userRole == UserRole.receptionist &&
                      searchQuery.isNotEmpty) {
                    schedules = state.schedules.where((schedule) {
                      return schedule.scheduleId
                          .toString()
                          .contains(searchQuery);
                    }).toList();
                  }

                  if (schedules.isEmpty) {
                    return Center(
                      child: Text(
                        searchQuery.isNotEmpty
                            ? 'No schedules found for ID: $searchQuery'
                            : 'No schedules found',
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 450),
                        child: Column(
                          children: schedules.map<Widget>((schedule) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: ScheduleCard(
                                schedule: schedule,
                                isReceptionist:
                                    userRole == UserRole.receptionist,
                                onStatusUpdated: () =>
                                    context.read<SchedulesCubit>().getSchedules(
                                          types: selectedTypes.isEmpty
                                              ? null
                                              : selectedTypes,
                                          statuses: selectedStatuses.isEmpty
                                              ? null
                                              : selectedStatuses,
                                        ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                }

                return const Center(child: Text('Unknown state'));
              },
            ),
          ),
        ],
      ),
    );
  }
}
