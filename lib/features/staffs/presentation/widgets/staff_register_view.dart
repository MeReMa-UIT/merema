import 'package:flutter/material.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/core/layers/presentation/widgets/app_field.dart';
import 'package:merema/core/layers/presentation/widgets/app_button.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/staffs/domain/usecases/register_staff.dart';
import 'package:merema/core/layers/data/model/account_req_params.dart';
import 'package:merema/features/staffs/data/models/staff_req_params.dart';
import 'package:dartz/dartz.dart' as dartz;

class StaffRegisterView extends StatefulWidget {
  final VoidCallback onCancel;
  final VoidCallback onSuccess;

  const StaffRegisterView({
    super.key,
    required this.onCancel,
    required this.onSuccess,
  });

  @override
  State<StaffRegisterView> createState() => _StaffRegisterViewState();
}

class _StaffRegisterViewState extends State<StaffRegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _citizenIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _fullNameController = TextEditingController();
  String _selectedGender = 'Nam';
  String _selectedRole = 'doctor';
  final _departmentController = TextEditingController();
  bool _isRegistering = false;

  @override
  void dispose() {
    _citizenIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dateOfBirthController.dispose();
    _fullNameController.dispose();
    _departmentController.dispose();
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

  Future<void> _registerStaff() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isRegistering = true;
    });

    try {
      String dateOfBirth = _dateOfBirthController.text;
      if (dateOfBirth.isNotEmpty && !dateOfBirth.endsWith('T00:00:00Z')) {
        dateOfBirth = '${dateOfBirth}T00:00:00Z';
      }

      final accountParams = AccountReqParams(
        citizenId: _citizenIdController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        role: _selectedRole,
      );

      final staffParams = StaffReqParams(
        dateOfBirth: dateOfBirth,
        department: _departmentController.text,
        fullName: _fullNameController.text,
        gender: _selectedGender,
      );

      final params = dartz.Tuple2<AccountReqParams, StaffReqParams>(
        accountParams,
        staffParams,
      );

      final result = await sl<RegisterStaffUseCase>().call(params);

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
              const SnackBar(content: Text('Staff registered successfully')),
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
                  'Register New Staff',
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
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        items: const [
                          DropdownMenuItem(
                              value: 'doctor', child: Text('Doctor')),
                          DropdownMenuItem(
                              value: 'receptionist',
                              child: Text('Receptionist')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value!;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Role',
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
                        labelText: 'Department',
                        controller: _departmentController,
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
                              onPressed: _isRegistering ? null : _registerStaff,
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
