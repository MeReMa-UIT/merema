import 'package:flutter/material.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/core/layers/presentation/widgets/app_field.dart';
import 'package:merema/core/layers/presentation/widgets/app_button.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/staffs/domain/usecases/update_staff.dart';
import 'package:merema/features/staffs/data/models/staff_req_params.dart';
import 'package:dartz/dartz.dart' as dartz;

class StaffUpdateInfoView extends StatefulWidget {
  final int staffId;
  final String staffName;
  final dynamic staffInfo;
  final VoidCallback onCancel;
  final VoidCallback onSuccess;

  const StaffUpdateInfoView({
    super.key,
    required this.staffId,
    required this.staffName,
    required this.staffInfo,
    required this.onCancel,
    required this.onSuccess,
  });

  @override
  State<StaffUpdateInfoView> createState() => _StaffUpdateInfoViewState();
}

class _StaffUpdateInfoViewState extends State<StaffUpdateInfoView> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  String _selectedGender = 'Nam';
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    final info = widget.staffInfo;
    _selectedGender = info.gender ?? 'Nam';

    _fullNameController.text = info.fullName ?? '';
    _departmentController.text = info.department ?? '';
    _dateOfBirthController.text = info.dateOfBirth?.split('T')[0] ?? '';
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

  Future<void> _updateStaff() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      String dateOfBirth = _dateOfBirthController.text;
      if (dateOfBirth.isNotEmpty && !dateOfBirth.endsWith('T00:00:00Z')) {
        dateOfBirth = '${dateOfBirth}T00:00:00Z';
      }

      final params = StaffReqParams(
        dateOfBirth: dateOfBirth,
        department: _departmentController.text,
        fullName: _fullNameController.text,
        gender: _selectedGender,
      );

      final result = await sl<UpdateStaffUseCase>().call(
        dartz.Tuple2(params, widget.staffId),
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
              const SnackBar(content: Text('Staff info updated successfully')),
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
                  widget.staffName.isNotEmpty
                      ? widget.staffName[0].toUpperCase()
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
                  'Edit ${widget.staffName}',
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
                            initialDateString: widget.staffInfo.dateOfBirth),
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
                        labelText: 'Department',
                        controller: _departmentController,
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
                              onPressed: _isUpdating ? null : _updateStaff,
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
