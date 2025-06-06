import 'package:flutter/material.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/core/layers/presentation/widgets/app_field.dart';
import 'package:merema/core/layers/presentation/widgets/app_button.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/patients/domain/usecases/register_patient.dart';
import 'package:merema/core/layers/data/model/account_req_params.dart';
import 'package:merema/features/patients/data/models/patient_req_params.dart';
import 'package:dartz/dartz.dart' as dartz;

class PatientRegisterView extends StatefulWidget {
  final VoidCallback onCancel;
  final VoidCallback onSuccess;

  const PatientRegisterView({
    super.key,
    required this.onCancel,
    required this.onSuccess,
  });

  @override
  State<PatientRegisterView> createState() => _PatientRegisterViewState();
}

class _PatientRegisterViewState extends State<PatientRegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _citizenIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _emergencyContactInfoController = TextEditingController();
  final _ethnicityController = TextEditingController();
  final _fullNameController = TextEditingController();
  String _selectedGender = 'Nam';
  final _healthInsuranceExpiredDateController = TextEditingController();
  final _healthInsuranceNumberController = TextEditingController();
  final _nationalityController = TextEditingController();
  bool _isRegistering = false;

  @override
  void dispose() {
    _citizenIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dateOfBirthController.dispose();
    _emergencyContactInfoController.dispose();
    _ethnicityController.dispose();
    _fullNameController.dispose();
    _healthInsuranceExpiredDateController.dispose();
    _healthInsuranceNumberController.dispose();
    _nationalityController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller,
      {bool allowFuture = false}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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

  Future<void> _registerPatient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isRegistering = true;
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

      final accountParams = AccountReqParams(
        citizenId: _citizenIdController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        role: 'patient',
      );

      final patientParams = PatientReqParams(
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

      final params = dartz.Tuple2<AccountReqParams, PatientReqParams>(
        accountParams,
        patientParams,
      );

      final result = await sl<RegisterPatientUseCase>().call(params);

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
              const SnackBar(content: Text('Patient registered successfully')),
            );
            widget.onSuccess();
          }
        },
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRegistering = false;
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
              const CircleAvatar(
                backgroundColor: AppPallete.primaryColor,
                radius: 20,
                child: Icon(
                  Icons.person_add,
                  color: AppPallete.backgroundColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Register New Patient',
                  style: TextStyle(
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
                        required: true,
                      ),
                      const SizedBox(height: 16),
                      AppField(
                        labelText: 'Citizen ID',
                        controller: _citizenIdController,
                        required: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter citizen ID';
                          }
                          if (!RegExp(r'^\d{9,12}$').hasMatch(value)) {
                            return 'Citizen ID must have 9 to 12 digits';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () =>
                            _selectDate(context, _dateOfBirthController),
                        child: AbsorbPointer(
                          child: AppField(
                            labelText: 'Date of Birth',
                            controller: _dateOfBirthController,
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
                        required: true,
                      ),
                      const SizedBox(height: 16),
                      AppField(
                        labelText: 'Ethnicity',
                        controller: _ethnicityController,
                        required: true,
                      ),
                      const SizedBox(height: 16),
                      AppField(
                        labelText: 'Address',
                        controller: _addressController,
                        required: true,
                      ),
                      const SizedBox(height: 16),
                      AppField(
                        labelText: 'Email',
                        controller: _emailController,
                        required: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter email';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Email must be in correct format';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AppField(
                        labelText: 'Phone',
                        controller: _phoneController,
                        required: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter phone';
                          }
                          if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                            return 'Phone must have exactly 10 digits';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AppField(
                        labelText: 'Health Insurance Number',
                        controller: _healthInsuranceNumberController,
                        required: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter health insurance number';
                          }
                          if (!RegExp(r'^[A-Za-z]{2}\d{13}$').hasMatch(value)) {
                            return 'Health insurance number must be in AB0123456789012 format (2 letters followed by 13 digits)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => _selectDate(
                            context, _healthInsuranceExpiredDateController,
                            allowFuture: true),
                        child: AbsorbPointer(
                          child: AppField(
                            labelText: 'Health Insurance Expired Date',
                            controller: _healthInsuranceExpiredDateController,
                            required: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppField(
                        labelText: 'Emergency Contact Info',
                        controller: _emergencyContactInfoController,
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
                              text: _isRegistering
                                  ? 'Registering...'
                                  : 'Register',
                              onPressed:
                                  _isRegistering ? null : _registerPatient,
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
