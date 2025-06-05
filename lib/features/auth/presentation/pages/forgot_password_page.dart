import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/layers/presentation/widgets/app_button.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/auth/domain/usecases/recovery.dart';
import 'package:merema/features/auth/presentation/pages/verification_code_page.dart';
import 'package:merema/core/layers/presentation/widgets/app_field.dart';
import 'package:merema/features/auth/presentation/widgets/auth_layout.dart';
import 'package:merema/features/auth/data/models/auth_req_params.dart';
import 'package:merema/core/layers/presentation/bloc/button_state.dart';
import 'package:merema/core/layers/presentation/bloc/button_state_cubit.dart';

class ForgotPasswordPage extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const ForgotPasswordPage(),
      );
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _citizenIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _citizenIdController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onNextPressed(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ButtonStateCubit>().execute(
            useCase: sl<RecoveryUseCase>(),
            params: RecoveryReqParams(
              citizenId: _citizenIdController.text,
              email: _emailController.text,
            ),
          );
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VerificationCodePage(
                  citizenId: _citizenIdController.text,
                  email: _emailController.text,
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: AuthLayout(
              showBackButton: true,
              children: [
                const Text(
                  'Forgot Password',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),
                AppField(
                  labelText: 'Email',
                  controller: _emailController,
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
                const SizedBox(height: 15),
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
                const SizedBox(height: 25),
                AppButton(
                  text: 'Next',
                  onPressed: () => _onNextPressed(context),
                  isLoading: state is ButtonLoadingState,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
