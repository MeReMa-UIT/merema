import 'package:flutter/material.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/core/layers/presentation/widgets/app_field.dart';
import 'package:merema/core/layers/presentation/widgets/app_button.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/patients/domain/usecases/register_patient.dart';
import 'package:merema/core/layers/data/model/account_req_params.dart';
import 'package:merema/features/patients/data/models/patient_register_req_params.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:merema/features/patients/presentation/pages/patients_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/layers/presentation/bloc/button_state.dart';
import 'package:merema/core/layers/presentation/bloc/button_state_cubit.dart';

class PatientRegisterPage extends StatefulWidget {
  const PatientRegisterPage({super.key});

  static Route route() => MaterialPageRoute(
        builder: (context) => const PatientRegisterPage(),
      );

  @override
  State<PatientRegisterPage> createState() => _PatientRegisterPageState();
}

class _PatientRegisterPageState extends State<PatientRegisterPage> {
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ButtonStateCubit(),
      child: BlocConsumer<ButtonStateCubit, ButtonState>(
        listener: (context, state) {
          if (state is ButtonErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.failure.message)),
            );
          } else if (state is ButtonSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Patient registered successfully')),
            );
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacement(PatientsPage.route());
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Register Patient'),
              backgroundColor: AppPallete.backgroundColor,
              foregroundColor: AppPallete.textColor,
            ),
            backgroundColor: AppPallete.backgroundColor,
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppField(
                      hintText: 'Full Name',
                      controller: _fullNameController,
                    ),
                    const SizedBox(height: 12),
                    AppField(
                      hintText: 'Citizen ID',
                      controller: _citizenIdController,
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
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => _selectDate(context, _dateOfBirthController),
                      child: AbsorbPointer(
                        child: AppField(
                          hintText: 'Date of Birth',
                          controller: _dateOfBirthController,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      items: const [
                        DropdownMenuItem(value: 'Nam', child: Text('Male')),
                        DropdownMenuItem(value: 'Nữ', child: Text('Female')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select gender';
                        }
                        return null;
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
                    const SizedBox(height: 12),
                    AppField(
                      hintText: 'Nationality',
                      controller: _nationalityController,
                    ),
                    const SizedBox(height: 12),
                    AppField(
                      hintText: 'Ethnicity',
                      controller: _ethnicityController,
                    ),
                    const SizedBox(height: 12),
                    AppField(
                      hintText: 'Address',
                      controller: _addressController,
                    ),
                    const SizedBox(height: 12),
                    AppField(
                      hintText: 'Email',
                      controller: _emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value) ||
                            !RegExp(r'^[\x00-\x7F]*$').hasMatch(value)) {
                          return 'Email must be in correct format and contain only ASCII characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    AppField(
                      hintText: 'Phone',
                      controller: _phoneController,
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
                    const SizedBox(height: 12),
                    AppField(
                      hintText: 'Health Insurance Number',
                      controller: _healthInsuranceNumberController,
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
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => _selectDate(
                          context, _healthInsuranceExpiredDateController,
                          allowFuture: true),
                      child: AbsorbPointer(
                        child: AppField(
                          hintText: 'Health Insurance Expired Date',
                          controller: _healthInsuranceExpiredDateController,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppField(
                      hintText: 'Emergency Contact Info',
                      controller: _emergencyContactInfoController,
                    ),
                    const SizedBox(height: 28),
                    AppButton(
                      text: 'Register',
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          String dateOfBirth = _dateOfBirthController.text;
                          if (dateOfBirth.isNotEmpty &&
                              !dateOfBirth.endsWith('T00:00:00Z')) {
                            dateOfBirth = '${dateOfBirth}T00:00:00Z';
                          }
                          String healthInsuranceExpiredDate =
                              _healthInsuranceExpiredDateController.text;
                          if (healthInsuranceExpiredDate.isNotEmpty &&
                              !healthInsuranceExpiredDate
                                  .endsWith('T00:00:00Z')) {
                            healthInsuranceExpiredDate =
                                '${healthInsuranceExpiredDate}T00:00:00Z';
                          }
                          final accountParams = AccountReqParams(
                            citizenId: _citizenIdController.text,
                            email: _emailController.text,
                            phone: _phoneController.text,
                            role: 'patient',
                          );
                          final patientParams = PatientRegisterReqParams(
                            address: _addressController.text,
                            dateOfBirth: dateOfBirth,
                            emergencyContactInfo:
                                _emergencyContactInfoController.text,
                            ethnicity: _ethnicityController.text,
                            fullName: _fullNameController.text,
                            gender: _selectedGender,
                            healthInsuranceExpiredDate:
                                healthInsuranceExpiredDate,
                            healthInsuranceNumber:
                                _healthInsuranceNumberController.text,
                            nationality: _nationalityController.text,
                          );
                          final params = dartz.Tuple2<AccountReqParams,
                              PatientRegisterReqParams>(
                            accountParams,
                            patientParams,
                          );
                          context.read<ButtonStateCubit>().execute(
                                useCase: sl<RegisterPatientUseCase>(),
                                params: params,
                              );
                        }
                      },
                      isLoading: state is ButtonLoadingState,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
