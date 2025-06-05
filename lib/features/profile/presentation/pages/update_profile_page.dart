import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/layers/presentation/widgets/app_field.dart';
import 'package:merema/core/layers/presentation/widgets/app_button.dart';
import 'package:merema/core/layers/presentation/widgets/custom_dropdown.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/profile/domain/usecases/update_profile.dart';
import 'package:merema/core/layers/presentation/bloc/button_state.dart';
import 'package:merema/core/layers/presentation/bloc/button_state_cubit.dart';
import 'package:merema/features/profile/presentation/pages/profile_page.dart';

class UpdateProfilePage extends StatefulWidget {
  final String citizenId;
  final String email;
  final String phone;
  const UpdateProfilePage({
    super.key,
    required this.citizenId,
    required this.email,
    required this.phone,
  });

  static Route route(
          {required String citizenId,
          required String email,
          required String phone}) =>
      MaterialPageRoute(
        builder: (context) => UpdateProfilePage(
          citizenId: citizenId,
          email: email,
          phone: phone,
        ),
      );

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _newValueController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedField = 'citizen_id';

  final List<Map<String, String>> _fieldOptions = [
    {'value': 'citizen_id', 'label': 'Citizen ID'},
    {'value': 'email', 'label': 'Email'},
    {'value': 'phone', 'label': 'Phone'},
    {'value': 'password', 'label': 'Password'},
  ];

  @override
  void dispose() {
    _newValueController.dispose();
    _confirmPasswordController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _getFieldLabel() {
    switch (_selectedField) {
      case 'citizen_id':
        return 'Citizen ID';
      case 'email':
        return 'Email';
      case 'phone':
        return 'Phone';
      case 'password':
        return 'New Password';
      default:
        return 'New Value';
    }
  }

  String _getHintText() {
    switch (_selectedField) {
      case 'citizen_id':
        return widget.citizenId;
      case 'email':
        return widget.email;
      case 'phone':
        return widget.phone;
      default:
        return '';
    }
  }

  String? Function(String?) _getValidator() {
    switch (_selectedField) {
      case 'citizen_id':
        return (value) {
          if (value == null || value.isEmpty) {
            return 'Citizen ID is required';
          }
          if (!RegExp(r'^\d{9,12}$').hasMatch(value)) {
            return 'Citizen ID must have 9 to 12 digits';
          }
          return null;
        };
      case 'email':
        return (value) {
          if (value == null || value.isEmpty) {
            return 'Email is required';
          }
          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
            return 'Email must be in correct format';
          }
          return null;
        };
      case 'phone':
        return (value) {
          if (value == null || value.isEmpty) {
            return 'Phone is required';
          }
          if (!RegExp(r'^\d{10}$').hasMatch(value)) {
            return 'Phone must have exactly 10 digits';
          }
          return null;
        };
      case 'password':
        return (value) {
          if (value == null || value.isEmpty) {
            return 'New password is required';
          }
          if (value.length < 6) {
            return 'Password must have at least 6 characters';
          }
          return null;
        };
      default:
        return (value) => null;
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
              const SnackBar(content: Text('Profile updated successfully')),
            );
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacement(ProfilePage.route());
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text('Update Profile')),
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32.0, vertical: 20.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomDropdown<String>(
                          selectedValue: _selectedField,
                          availableItems: _fieldOptions
                              .map((option) => option['value']!)
                              .toList(),
                          getDisplayText: (value) {
                            return _fieldOptions.firstWhere(
                                (option) => option['value'] == value)['label']!;
                          },
                          onChanged: (value) {
                            setState(() {
                              _selectedField = value!;
                              _newValueController.clear();
                            });
                          },
                          labelText: 'Field to Update',
                        ),
                        const SizedBox(height: 12),
                        AppField(
                          labelText: _getFieldLabel(),
                          hintText: _getHintText(),
                          controller: _newValueController,
                          alwaysShowLabel: _selectedField != 'password',
                          validator: _getValidator(),
                          isPassword: _selectedField == 'password',
                        ),
                        const SizedBox(height: 12),
                        if (_selectedField == 'password') ...[
                          AppField(
                            labelText: 'Confirm New Password',
                            controller: _confirmPasswordController,
                            isPassword: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your new password';
                              }
                              if (value.length < 6) {
                                return 'Password must have at least 6 characters';
                              }
                              if (value != _newValueController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                        ],
                        AppField(
                          labelText: _selectedField == 'password'
                              ? 'Current Password'
                              : 'Password',
                          controller: _passwordController,
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            if (value.length < 6) {
                              return 'Password must have at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),
                        AppButton(
                          text: 'Update',
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              final updateData = {
                                'field': _selectedField,
                                'new_value': _newValueController.text,
                                'password': _passwordController.text,
                              };

                              context.read<ButtonStateCubit>().execute(
                                    useCase: sl<UpdateProfileUseCase>(),
                                    params: updateData,
                                  );
                            }
                          },
                          isLoading: state is ButtonLoadingState,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
