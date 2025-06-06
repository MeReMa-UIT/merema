import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/layers/presentation/widgets/people_sidebar.dart';
import 'package:merema/features/staffs/presentation/bloc/staffs_state.dart';
import 'package:merema/features/staffs/presentation/bloc/staffs_state_cubit.dart';

class StaffsSidebar extends StatefulWidget {
  final Function(int staffId, String staffName) onStaffSelected;
  final VoidCallback onShowRegisterView;
  final int? selectedStaffId;

  const StaffsSidebar({
    super.key,
    required this.onStaffSelected,
    required this.onShowRegisterView,
    this.selectedStaffId,
  });

  @override
  State<StaffsSidebar> createState() => _StaffsSidebarState();
}

class _StaffsSidebarState extends State<StaffsSidebar> {
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
    return BlocBuilder<StaffsCubit, StaffsState>(
      builder: (context, state) {
        final staffs = state is StaffsLoaded ? state.filteredStaffs : [];
        final isLoading = state is StaffsLoading;
        final hasError = state is StaffsError;
        final errorMessage = state is StaffsError ? state.message : null;
        final selectedStaff = state is StaffsLoaded
            ? staffs
                .where((s) => s.staffId == widget.selectedStaffId)
                .firstOrNull
            : null;

        return PeopleSidebar(
          title: 'Staffs',
          people: staffs,
          isLoading: isLoading,
          hasError: hasError,
          errorMessage: errorMessage,
          onPersonSelected: (staff) {
            widget.onStaffSelected(staff.staffId, staff.fullName);
          },
          onShowRegisterView: widget.onShowRegisterView,
          onRetry: () => context.read<StaffsCubit>().getStaffs(),
          onSearch: _onSearch,
          onClearSearch: _onClear,
          searchController: _searchController,
          selectedPerson: selectedStaff,
          getPersonId: (staff) => staff.staffId.toString(),
          getPersonName: (staff) => staff.fullName,
          getPersonSubtitle: (staff) =>
              'Department: ${staff.department}\nGender: ${staff.gender}',
          showRegisterButton: true,
        );
      },
    );
  }
}
