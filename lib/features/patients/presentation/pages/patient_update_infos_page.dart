import 'package:flutter/material.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/core/layers/presentation/widgets/app_field.dart';
import 'package:merema/core/layers/presentation/widgets/app_button.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/patients/domain/usecases/update_patient.dart';
import 'package:merema/features/patients/data/models/patient_req_params.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:merema/features/patients/presentation/pages/patient_infos_page.dart';

class PatientUpdateInfosPage extends StatefulWidget {
  final int patientId;
  final dynamic patientInfo;
  const PatientUpdateInfosPage(
      {super.key, required this.patientId, required this.patientInfo});

  static Route route(int patientId, dynamic patientInfo) => MaterialPageRoute(
        builder: (context) => PatientUpdateInfosPage(
            patientId: patientId, patientInfo: patientInfo),
      );

  @override
  State<PatientUpdateInfosPage> createState() => _PatientUpdateInfosPageState();
}

class _PatientUpdateInfosPageState extends State<PatientUpdateInfosPage> {
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

  @override
  void initState() {
    super.initState();
    final info = widget.patientInfo;
    _selectedGender = info.gender ?? 'Nam';
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

  @override
  Widget build(BuildContext context) {
    final info = widget.patientInfo;
    return Scaffold(
      appBar: AppBar(title: const Text('Update Patient Info')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppField(
                labelText: 'Full Name',
                hintText: info.fullName,
                controller: _fullNameController,
                alwaysShowLabel: true,
                required: false,
                validator: null,
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _selectDate(context, _dateOfBirthController,
                    initialDateString: info.dateOfBirth),
                child: AbsorbPointer(
                  child: AppField(
                    labelText: 'Date of Birth',
                    hintText: info.dateOfBirth.split('T')[0],
                    controller: _dateOfBirthController,
                    alwaysShowLabel: true,
                    required: false,
                    validator: null,
                  ),
                ),
              ),
              const SizedBox(height: 12),
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
                validator: null,
                decoration: InputDecoration(
                  labelText: 'Gender',
                  hintText: info.gender,
                  border: const OutlineInputBorder(),
                  labelStyle: const TextStyle(color: AppPallete.textColor),
                  floatingLabelStyle:
                      const TextStyle(color: AppPallete.textColor),
                ),
                dropdownColor: AppPallete.backgroundColor,
                style: const TextStyle(color: AppPallete.textColor),
                iconEnabledColor: AppPallete.textColor,
              ),
              const SizedBox(height: 12),
              AppField(
                labelText: 'Nationality',
                hintText: info.nationality,
                controller: _nationalityController,
                alwaysShowLabel: true,
                required: false,
                validator: null,
              ),
              const SizedBox(height: 12),
              AppField(
                labelText: 'Ethnicity',
                hintText: info.ethnicity,
                controller: _ethnicityController,
                alwaysShowLabel: true,
                required: false,
                validator: null,
              ),
              const SizedBox(height: 12),
              AppField(
                labelText: 'Address',
                hintText: info.address,
                controller: _addressController,
                alwaysShowLabel: true,
                required: false,
                validator: null,
              ),
              const SizedBox(height: 12),
              AppField(
                labelText: 'Health Insurance Number',
                hintText: info.healthInsuranceNumber,
                controller: _healthInsuranceNumberController,
                alwaysShowLabel: true,
                required: false,
                validator: null,
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _selectDate(
                    context, _healthInsuranceExpiredDateController,
                    allowFuture: true,
                    initialDateString: info.healthInsuranceExpiredDate),
                child: AbsorbPointer(
                  child: AppField(
                    labelText: 'Health Insurance Expired Date',
                    hintText: info.healthInsuranceExpiredDate.split('T')[0],
                    controller: _healthInsuranceExpiredDateController,
                    alwaysShowLabel: true,
                    required: false,
                    validator: null,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AppField(
                labelText: 'Emergency Contact Info',
                hintText: info.emergencyContactInfo,
                controller: _emergencyContactInfoController,
                alwaysShowLabel: true,
                required: false,
                validator: null,
              ),
              const SizedBox(height: 28),
              AppButton(
                text: 'Update',
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    String dateOfBirth = _dateOfBirthController.text;
                    if (dateOfBirth.isNotEmpty &&
                        !dateOfBirth.endsWith('T00:00:00Z')) {
                      dateOfBirth = '${dateOfBirth}T00:00:00Z';
                    }
                    String healthInsuranceExpiredDate =
                        _healthInsuranceExpiredDateController.text;
                    if (healthInsuranceExpiredDate.isNotEmpty &&
                        !healthInsuranceExpiredDate.endsWith('T00:00:00Z')) {
                      healthInsuranceExpiredDate =
                          '${healthInsuranceExpiredDate}T00:00:00Z';
                    }
                    final params = PatientReqParams(
                      address: _addressController.text,
                      dateOfBirth: dateOfBirth,
                      emergencyContactInfo:
                          _emergencyContactInfoController.text,
                      ethnicity: _ethnicityController.text,
                      fullName: _fullNameController.text,
                      gender: _selectedGender,
                      healthInsuranceExpiredDate: healthInsuranceExpiredDate,
                      healthInsuranceNumber:
                          _healthInsuranceNumberController.text,
                      nationality: _nationalityController.text,
                    );
                    final result = await sl<UpdatePatientUseCase>().call(
                      dartz.Tuple2(params, widget.patientId),
                    );
                    result.fold(
                      (error) => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error.toString())),
                      ),
                      (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Patient info updated successfully')),
                        );
                        Navigator.of(context).pop();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) =>
                                PatientInfosPage(patientId: widget.patientId),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
