import 'package:flutter/material.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/core/layers/presentation/widgets/app_field.dart';
import 'package:merema/core/layers/presentation/widgets/app_button.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/staffs/domain/usecases/register_staff.dart';
import 'package:merema/core/layers/data/model/account_req_params.dart';
import 'package:merema/features/staffs/data/models/staff_req_params.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:merema/features/staffs/presentation/pages/staffs_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/layers/presentation/bloc/button_state.dart';
import 'package:merema/core/layers/presentation/bloc/button_state_cubit.dart';

class StaffRegisterPage extends StatefulWidget {
  const StaffRegisterPage({super.key});

  static Route route() => MaterialPageRoute(
        builder: (context) => const StaffRegisterPage(),
      );

  @override
  State<StaffRegisterPage> createState() => _StaffRegisterPageState();
}

class _StaffRegisterPageState extends State<StaffRegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _citizenIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _fullNameController = TextEditingController();
  String _selectedGender = 'Nam';
  String _selectedRole = 'doctor';
  final _departmentController = TextEditingController();

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
              const SnackBar(content: Text('Staff registered successfully')),
            );
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacement(StaffsPage.route());
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Register Staff'),
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
                      labelText: 'Full Name',
                      controller: _fullNameController,
                    ),
                    const SizedBox(height: 12),
                    AppField(
                      labelText: 'Citizen ID',
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
                          labelText: 'Date of Birth',
                          controller: _dateOfBirthController,
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
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      items: const [
                        DropdownMenuItem(
                            value: 'doctor', child: Text('Doctor')),
                        DropdownMenuItem(
                            value: 'receptionist', child: Text('Receptionist')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select role';
                        }
                        return null;
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
                    const SizedBox(height: 12),
                    AppField(
                      labelText: 'Department',
                      controller: _departmentController,
                    ),
                    const SizedBox(height: 12),
                    AppField(
                      labelText: 'Email',
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
                      labelText: 'Phone',
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
                          final params =
                              dartz.Tuple2<AccountReqParams, StaffReqParams>(
                            accountParams,
                            staffParams,
                          );
                          context.read<ButtonStateCubit>().execute(
                                useCase: sl<RegisterStaffUseCase>(),
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
