import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/features/patients/presentation/bloc/patient_infos_state.dart';
import 'package:merema/features/patients/presentation/bloc/patient_infos_state_cubit.dart';
import 'package:merema/features/patients/presentation/widgets/patient_update_info_view.dart';

class PatientInfoDoctorView extends StatefulWidget {
  final int patientId;
  final String patientName;
  final Function(bool)? onEditingChanged;

  const PatientInfoDoctorView({
    super.key,
    required this.patientId,
    required this.patientName,
    this.onEditingChanged,
  });

  @override
  State<PatientInfoDoctorView> createState() => _PatientInfoDoctorViewState();
}

class _PatientInfoDoctorViewState extends State<PatientInfoDoctorView> {
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PatientInfosCubit>().getInfos(widget.patientId);
      }
    });
  }

  @override
  void didUpdateWidget(PatientInfoDoctorView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.patientId != widget.patientId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<PatientInfosCubit>().getInfos(widget.patientId);
        }
      });
      _isEditing = false;
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
    widget.onEditingChanged?.call(_isEditing);
  }

  void _onUpdateSuccess() {
    setState(() {
      _isEditing = false;
    });
    widget.onEditingChanged?.call(false);
    context.read<PatientInfosCubit>().getInfos(widget.patientId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientInfosCubit, PatientInfosState>(
      builder: (context, state) {
        if (state is PatientInfosLoaded && _isEditing) {
          return Expanded(
            child: PatientUpdateInfoView(
              patientId: widget.patientId,
              patientName: widget.patientName,
              patientInfo: state.patientInfo,
              onCancel: () {
                setState(() => _isEditing = false);
                widget.onEditingChanged?.call(false);
              },
              onSuccess: _onUpdateSuccess,
            ),
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
                        fontSize: 24,
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
                  if (state is PatientInfosLoading)
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  if (state is PatientInfosError)
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(
                        Icons.error_outline,
                        color: AppPallete.errorColor,
                        size: 24,
                      ),
                    ),
                ],
              ),
            ),
            if (state is PatientInfosLoaded && !_isEditing)
              _buildInfoCards(state.patientInfo),
            const Divider(),
          ],
        );
      },
    );
  }

  Widget _buildInfoCards(dynamic patientInfo) {
    if (patientInfo == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Patient information details are not available',
            style: TextStyle(color: AppPallete.textColor),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final dateOfBirth = patientInfo.dateOfBirth?.split('T')[0] ?? 'N/A';
    final healthInsuranceExpiredDate =
        patientInfo.healthInsuranceExpiredDate?.split('T')[0] ?? 'N/A';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuadFieldRow(
              'DOB',
              dateOfBirth,
              'Gender',
              patientInfo.gender ?? 'N/A',
              'Nationality',
              patientInfo.nationality ?? 'N/A',
              'Ethnicity',
              patientInfo.ethnicity ?? 'N/A'),
          const SizedBox(height: 8),
          _buildQuadFieldRow(
              'Address',
              patientInfo.address ?? 'N/A',
              'Emergency Contact',
              patientInfo.emergencyContactInfo ?? 'N/A',
              'Insurance Number',
              patientInfo.healthInsuranceNumber ?? 'N/A',
              'Insurance Expiry',
              healthInsuranceExpiredDate),
        ],
      ),
    );
  }

  Widget _buildSingleFieldRow(String label, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppPallete.darkGrayColor,
              fontSize: 15,
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              color: AppPallete.textColor,
              fontSize: 15,
            ),
          ),
        ],
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
    );
  }

  Widget _buildQuadFieldRow(
      String label1,
      String value1,
      String label2,
      String value2,
      String label3,
      String value3,
      String label4,
      String value4) {
    return Row(
      children: [
        Expanded(
          child: _buildSingleFieldRow(label1, value1),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSingleFieldRow(label2, value2),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSingleFieldRow(label3, value3),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSingleFieldRow(label4, value4),
        ),
      ],
    );
  }
}
