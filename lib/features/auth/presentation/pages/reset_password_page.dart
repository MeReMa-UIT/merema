import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/auth/domain/usecases/recovery.dart';
import 'package:merema/features/auth/presentation/pages/login_page.dart';
import 'package:merema/features/auth/presentation/widgets/auth_button.dart';
import 'package:merema/features/auth/presentation/widgets/auth_field.dart';
import 'package:merema/features/auth/presentation/widgets/auth_layout.dart';
import 'package:merema/features/auth/data/models/auth_req_params.dart';
import 'package:merema/features/auth/presentation/bloc/button_bloc/button_state.dart';
import 'package:merema/features/auth/presentation/bloc/button_bloc/button_state_cubit.dart';

class ResetPasswordPage extends StatefulWidget {
  static route({required String token, required String email}) =>
      MaterialPageRoute(
        builder: (context) => ResetPasswordPage(token: token, email: email),
      );

  final String token;
  final String email;

  const ResetPasswordPage({
    super.key,
    required this.token,
    required this.email,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onResetPasswordPressed(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ButtonStateCubit>().execute(
            useCase: sl<RecoveryResetUseCase>(),
            params: RecoveryResetReqParams(
              token: widget.token,
              newPassword: _newPasswordController.text,
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đặt lại mật khẩu thành công')),
            );

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(email: widget.email),
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: Form(
              key: _formKey,
              child: AuthLayout(
                showBackButton: true,
                children: [
                  const Text(
                    'Tạo mật khẩu mới',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 25),
                  AuthField(
                    hintText: 'Mật khẩu mới',
                    controller: _newPasswordController,
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu mới';
                      }
                      if (value.length < 6) {
                        return 'Mật khẩu phải có ít nhất 6 kí tự';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  AuthField(
                    hintText: 'Xác nhận mật khẩu',
                    controller: _confirmPasswordController,
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập lại mật khẩu';
                      }
                      if (value.length < 6) {
                        return 'Mật khẩu phải có ít nhất 6 kí tự';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Mật khẩu không khớp';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 25),
                  AuthButton(
                    text: 'Đặt lại mật khẩu',
                    onPressed: () => _onResetPasswordPressed(context),
                    isLoading: state is ButtonLoadingState,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
