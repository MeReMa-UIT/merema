import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/layers/domain/entities/user_role.dart';
import 'package:merema/core/layers/presentation/widgets/people_sidebar.dart';
import 'package:merema/features/patients/presentation/bloc/patients_state_cubit.dart';
import 'package:merema/features/patients/presentation/bloc/patients_state.dart';

class PatientsSidebar extends StatefulWidget {
  final Function(int patientId, String patientName) onPatientSelected;
  final VoidCallback? onShowRegisterView;
  final int? selectedPatientId;

  const PatientsSidebar({
    super.key,
    required this.onPatientSelected,
    this.onShowRegisterView,
    this.selectedPatientId,
  });

  @override
  State<PatientsSidebar> createState() => _PatientsSidebarState();
}

class _PatientsSidebarState extends State<PatientsSidebar> {
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
    return BlocBuilder<PatientsCubit, PatientsState>(
      builder: (context, state) {
        final patients = state is PatientsLoaded ? state.filteredPatients : [];
        final isLoading = state is PatientsLoading;
        final hasError = state is PatientsError;
        final errorMessage = state is PatientsError ? state.message : null;
        final showRegisterButton =
            state is PatientsLoaded && state.userRole == UserRole.receptionist;
        final selectedPatient = state is PatientsLoaded
            ? patients
                .where((p) => p.patientId == widget.selectedPatientId)
                .firstOrNull
            : null;

        return PeopleSidebar(
          title: 'Patients',
          people: patients,
          isLoading: isLoading,
          hasError: hasError,
          errorMessage: errorMessage,
          onPersonSelected: (patient) {
            widget.onPatientSelected(patient.patientId, patient.fullName);
          },
          onShowRegisterView:
              showRegisterButton ? widget.onShowRegisterView : null,
          onRetry: () => context.read<PatientsCubit>().getPatients(),
          onSearch: _onSearch,
          onClearSearch: _onClear,
          searchController: _searchController,
          selectedPerson: selectedPatient,
          getPersonId: (patient) => patient.patientId.toString(),
          getPersonName: (patient) => patient.fullName,
          getPersonSubtitle: (patient) =>
              'DOB: ${patient.dateOfBirth.split('T')[0]}\nGender: ${patient.gender}',
          showRegisterButton: showRegisterButton,
        );
      },
    );
  }
}
