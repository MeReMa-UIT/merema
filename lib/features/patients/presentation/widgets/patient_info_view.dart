import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/core/layers/presentation/widgets/info_card.dart';
import 'package:merema/features/patients/presentation/bloc/patient_infos_state.dart';
import 'package:merema/features/patients/presentation/bloc/patient_infos_state_cubit.dart';
import 'package:merema/features/patients/presentation/widgets/patient_update_info_view.dart';

class PatientInfoView extends StatefulWidget {
  final int patientId;
  final String patientName;

  const PatientInfoView({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<PatientInfoView> createState() => _PatientInfoViewState();
}

class _PatientInfoViewState extends State<PatientInfoView> {
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    context.read<PatientInfosCubit>().getInfos(widget.patientId);
  }

  @override
  void didUpdateWidget(PatientInfoView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.patientId != widget.patientId) {
      context.read<PatientInfosCubit>().getInfos(widget.patientId);
      _isEditing = false;
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _onUpdateSuccess() {
    setState(() {
      _isEditing = false;
    });
    // Refresh the patient info
    context.read<PatientInfosCubit>().getInfos(widget.patientId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientInfosCubit, PatientInfosState>(
      builder: (context, state) {
        if (state is PatientInfosLoaded && _isEditing) {
          return PatientUpdateInfoView(
            patientId: widget.patientId,
            patientName: widget.patientName,
            patientInfo: state.patientInfo,
            onCancel: _toggleEditMode,
            onSuccess: _onUpdateSuccess,
          );
        }

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppPallete.backgroundColor,
                border: Border(
                  bottom: BorderSide(
                    color: AppPallete.lightGrayColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppPallete.primaryColor,
                    radius: 20,
                    child: Text(
                      widget.patientName.isNotEmpty
                          ? widget.patientName[0].toUpperCase()
                          : '',
                      style: const TextStyle(
                        color: AppPallete.backgroundColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.patientName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppPallete.textColor,
                      ),
                    ),
                  ),
                  if (state is PatientInfosLoaded)
                    IconButton(
                      icon: const Icon(Icons.edit,
                          color: AppPallete.primaryColor),
                      tooltip: 'Edit Info',
                      onPressed: _toggleEditMode,
                    ),
                ],
              ),
            ),
            Expanded(
              child: _buildContent(state),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContent(PatientInfosState state) {
    if (state is PatientInfosLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppPallete.primaryColor,
        ),
      );
    }

    if (state is PatientInfosError) {
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

    if (state is PatientInfosLoaded) {
      final patient = state.patientInfo;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoCard(
                  title: 'Personal Information',
                  icon: Icons.person,
                  fields: [
                    InfoField(label: 'Full Name', value: patient.fullName),
                    InfoField(
                        label: 'Date of Birth',
                        value: patient.dateOfBirth.split('T')[0]),
                    InfoField(label: 'Gender', value: patient.gender),
                  ],
                ),
                const SizedBox(height: 16),
                InfoCard(
                  title: 'Contact Information',
                  icon: Icons.contact_phone,
                  fields: [
                    InfoField(label: 'Address', value: patient.address),
                    InfoField(
                        label: 'Emergency Contact',
                        value: patient.emergencyContactInfo),
                  ],
                ),
                const SizedBox(height: 16),
                InfoCard(
                  title: 'Background Information',
                  icon: Icons.public,
                  fields: [
                    InfoField(label: 'Nationality', value: patient.nationality),
                    InfoField(label: 'Ethnicity', value: patient.ethnicity),
                  ],
                ),
                const SizedBox(height: 16),
                InfoCard(
                  title: 'Health Insurance',
                  icon: Icons.health_and_safety,
                  fields: [
                    InfoField(
                        label: 'Insurance Number',
                        value: patient.healthInsuranceNumber),
                    InfoField(
                        label: 'Expiry Date',
                        value:
                            patient.healthInsuranceExpiredDate.split('T')[0]),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const Center(
      child: Text('No patient information available'),
    );
  }
}
