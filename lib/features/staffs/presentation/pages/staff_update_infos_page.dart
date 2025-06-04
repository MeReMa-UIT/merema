import 'package:flutter/material.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/core/layers/presentation/widgets/app_field.dart';
import 'package:merema/core/layers/presentation/widgets/app_button.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/staffs/domain/usecases/update_staff.dart';
import 'package:merema/features/staffs/data/models/staff_req_params.dart';
import 'package:merema/core/layers/data/model/account_req_params.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:merema/features/staffs/presentation/pages/staff_infos_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/layers/presentation/bloc/button_state.dart';
import 'package:merema/core/layers/presentation/bloc/button_state_cubit.dart';

class StaffUpdateInfosPage extends StatefulWidget {
  final int staffId;
  final dynamic staffInfo;
  const StaffUpdateInfosPage(
      {super.key, required this.staffId, required this.staffInfo});

  static Route route(int staffId, dynamic staffInfo) => MaterialPageRoute(
        builder: (context) =>
            StaffUpdateInfosPage(staffId: staffId, staffInfo: staffInfo),
      );

  @override
  State<StaffUpdateInfosPage> createState() => _StaffUpdateInfosPageState();
}

class _StaffUpdateInfosPageState extends State<StaffUpdateInfosPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  String _selectedGender = 'Nam';

  @override
  void initState() {
    super.initState();
    final info = widget.staffInfo;
    _selectedGender = info.gender ?? 'Nam';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _departmentController.dispose();
    _dateOfBirthController.dispose();
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
              const SnackBar(content: Text('Staff info updated successfully')),
            );
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => StaffInfosPage(staffId: widget.staffId),
              ),
            );
          }
        },
        builder: (context, state) {
          final info = widget.staffInfo;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Update Staff Info'),
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
                          hintText: info.dateOfBirth,
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
                        labelStyle:
                            const TextStyle(color: AppPallete.textColor),
                        floatingLabelStyle:
                            const TextStyle(color: AppPallete.textColor),
                      ),
                      dropdownColor: AppPallete.backgroundColor,
                      style: const TextStyle(color: AppPallete.textColor),
                      iconEnabledColor: AppPallete.textColor,
                    ),
                    const SizedBox(height: 12),
                    AppField(
                      labelText: 'Department',
                      hintText: info.department,
                      controller: _departmentController,
                      alwaysShowLabel: true,
                      required: false,
                      validator: null,
                    ),
                    const SizedBox(height: 28),
                    AppButton(
                      text: 'Update',
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          String dateOfBirth = _dateOfBirthController.text;
                          if (dateOfBirth.isNotEmpty &&
                              !dateOfBirth.endsWith('T00:00:00Z')) {
                            dateOfBirth = '${dateOfBirth}T00:00:00Z';
                          }
                          final accountParams = AccountReqParams(
                            citizenId: info.citizenId,
                            email: info.email,
                            phone: info.phone,
                            role: info.role,
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
                                useCase: sl<UpdateStaffUseCase>(),
                                params: dartz.Tuple2(params, widget.staffId),
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
