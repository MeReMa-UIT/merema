import 'package:flutter/material.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/core/layers/presentation/widgets/app_field.dart';
import 'package:merema/core/layers/presentation/widgets/app_button.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/patients/domain/usecases/update_patient.dart';
import 'package:merema/features/patients/data/models/patient_req_params.dart';
import 'package:dartz/dartz.dart' as dartz;

class PatientUpdateInfoView extends StatefulWidget {
  final int patientId;
  final String patientName;
  final dynamic patientInfo;
  final VoidCallback onCancel;
  final VoidCallback onSuccess;

  const PatientUpdateInfoView({
    super.key,
    required this.patientId,
    required this.patientName,
    required this.patientInfo,
    required this.onCancel,
    required this.onSuccess,
  });

  @override
  State<PatientUpdateInfoView> createState() => _PatientUpdateInfoViewState();
}

class _PatientUpdateInfoViewState extends State<PatientUpdateInfoView> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _emergencyContactInfoController = TextEditingController();
  final _ethnicityController = TextEditingController();
  String _selectedGender = 'Nam';
  final _healthInsuranceExpiredDateController = TextEditingController();
  final _healthInsuranceNumberController = TextEditingController();
  final _nationalityController = TextEditingController();
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    final info = widget.patientInfo;
    _selectedGender = info.gender ?? 'Nam';

    _fullNameController.text = info.fullName ?? '';
    _addressController.text = info.address ?? '';
    _dateOfBirthController.text = info.dateOfBirth?.split('T')[0] ?? '';
    _emergencyContactInfoController.text = info.emergencyContactInfo ?? '';
    _ethnicityController.text = info.ethnicity ?? '';
    _healthInsuranceExpiredDateController.text =
        info.healthInsuranceExpiredDate?.split('T')[0] ?? '';
    _healthInsuranceNumberController.text = info.healthInsuranceNumber ?? '';
    _nationalityController.text = info.nationality ?? '';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _addressController.dispose();
    _dateOfBirthController.dispose();
    _emergencyContactInfoController.dispose();
    _ethnicityController.dispose();
    _healthInsuranceExpiredDateController.dispose();
    _healthInsuranceNumberController.dispose();
    _nationalityController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller,
      {bool allowFuture = false, String? initialDateString}) async {
    DateTime initialDate = DateTime.now();
    if (initialDateString != null && initialDateString.isNotEmpty) {
      try {
        initialDate = DateTime.parse(initialDateString);
      } catch (_) {}
    }
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: allowFuture ? DateTime(2100) : DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppPallete.primaryColor,
              onPrimary: AppPallete.textColor,
              onSurface: AppPallete.textColor,
            ),
            dialogBackgroundColor: AppPallete.backgroundColor,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {});
    }
  }

  Future<void> _updatePatient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      String dateOfBirth = _dateOfBirthController.text;
      if (dateOfBirth.isNotEmpty && !dateOfBirth.endsWith('T00:00:00Z')) {
        dateOfBirth = '${dateOfBirth}T00:00:00Z';
      }
      String healthInsuranceExpiredDate =
          _healthInsuranceExpiredDateController.text;
      if (healthInsuranceExpiredDate.isNotEmpty &&
          !healthInsuranceExpiredDate.endsWith('T00:00:00Z')) {
        healthInsuranceExpiredDate = '${healthInsuranceExpiredDate}T00:00:00Z';
      }

      final params = PatientReqParams(
        address: _addressController.text,
        dateOfBirth: dateOfBirth,
        emergencyContactInfo: _emergencyContactInfoController.text,
        ethnicity: _ethnicityController.text,
        fullName: _fullNameController.text,
        gender: _selectedGender,
        healthInsuranceExpiredDate: healthInsuranceExpiredDate,
        healthInsuranceNumber: _healthInsuranceNumberController.text,
        nationality: _nationalityController.text,
      );

      final result = await sl<UpdatePatientUseCase>().call(
        dartz.Tuple2(params, widget.patientId),
      );

      result.fold(
        (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error.toString())),
            );
          }
        },
        (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Patient info updated successfully')),
            );
            widget.onSuccess();
          }
        },
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  'Edit ${widget.patientName}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppPallete.textColor,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppPallete.errorColor),
                tooltip: 'Cancel',
                onPressed: widget.onCancel,
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppField(
                        labelText: 'Full Name',
                        controller: _fullNameController,
                        alwaysShowLabel: true,
                        required: true,
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => _selectDate(
                            context, _dateOfBirthController,
                            initialDateString: widget.patientInfo.dateOfBirth),
                        child: AbsorbPointer(
                          child: AppField(
                            labelText: 'Date of Birth',
                            controller: _dateOfBirthController,
                            alwaysShowLabel: true,
                            required: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        items: const [
                          DropdownMenuItem(value: 'Nam', child: Text('Nam')),
                          DropdownMenuItem(value: 'Nữ', child: Text('Nữ')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value!;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Gender',
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(color: AppPallete.textColor),
                          floatingLabelStyle:
                              TextStyle(color: AppPallete.textColor),
                        ),
                        dropdownColor: AppPallete.backgroundColor,
                        style: const TextStyle(color: AppPallete.textColor),
                        iconEnabledColor: AppPallete.textColor,
                      ),
                      const SizedBox(height: 16),
                      AppField(
                        labelText: 'Nationality',
                        controller: _nationalityController,
                        alwaysShowLabel: true,
                        required: true,
                      ),
                      const SizedBox(height: 16),
                      AppField(
                        labelText: 'Ethnicity',
                        controller: _ethnicityController,
                        alwaysShowLabel: true,
                        required: true,
                      ),
                      const SizedBox(height: 16),
                      AppField(
                        labelText: 'Address',
                        controller: _addressController,
                        alwaysShowLabel: true,
                        required: true,
                      ),
                      const SizedBox(height: 16),
                      AppField(
                        labelText: 'Health Insurance Number',
                        controller: _healthInsuranceNumberController,
                        alwaysShowLabel: true,
                        required: true,
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => _selectDate(
                            context, _healthInsuranceExpiredDateController,
                            allowFuture: true,
                            initialDateString:
                                widget.patientInfo.healthInsuranceExpiredDate),
                        child: AbsorbPointer(
                          child: AppField(
                            labelText: 'Health Insurance Expired Date',
                            controller: _healthInsuranceExpiredDateController,
                            alwaysShowLabel: true,
                            required: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppField(
                        labelText: 'Emergency Contact Info',
                        controller: _emergencyContactInfoController,
                        alwaysShowLabel: true,
                        required: true,
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              text: 'Cancel',
                              onPressed: widget.onCancel,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppButton(
                              text: _isUpdating ? 'Updating...' : 'Update',
                              onPressed: _isUpdating ? null : _updatePatient,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
