import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/features/auth/presentation/bloc/button_bloc/button_state.dart';
import 'package:merema/features/auth/presentation/bloc/button_bloc/button_state_cubit.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/features/auth/domain/usecases/login.dart';
import 'package:merema/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:merema/features/auth/presentation/widgets/auth_button.dart';
import 'package:merema/features/auth/presentation/widgets/auth_field.dart';
import 'package:merema/features/auth/presentation/widgets/auth_layout.dart';
import 'package:merema/features/auth/data/models/auth_req_params.dart';
import 'package:merema/features/home/presentation/pages/home_page.dart';

class LoginPage extends StatefulWidget {
  static route(String? email) => MaterialPageRoute(
        builder: (context) => LoginPage(email: email ?? ''),
      );

  final String email;

  const LoginPage({super.key, this.email = ''});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ButtonStateCubit>().execute(
            useCase: sl<LoginUseCase>(),
            params: LoginReqParams(
              email: _emailController.text,
              password: _passwordController.text,
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
            if (state.failure.statusCode == 401) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Email hoặc mật khẩu không chính xác')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.failure.message)),
              );
            }
          } else if (state is ButtonSuccessState) {
            Navigator.pushReplacement(context, HomePage.route());
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: Form(
              key: _formKey,
              child: AuthLayout(
                children: [
                  const Text(
                    'Đăng nhập',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 25),
                  AuthField(
                    hintText: 'Email',
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Vui lòng nhập địa chỉ email hợp lệ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  AuthField(
                    hintText: 'Mật khẩu',
                    controller: _passwordController,
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu';
                      }
                      if (value.length < 6) {
                        return 'Mật khẩu phải có ít nhất 6 ký tự';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 25),
                  AuthButton(
                    text: 'Đăng nhập',
                    onPressed: () => _onLoginPressed(context),
                    isLoading: state is ButtonLoadingState,
                  ),
                  const SizedBox(height: 10),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (_) => setState(() => _isHovering = true),
                    onExit: (_) => setState(() => _isHovering = false),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(context, ForgotPasswordPage.route());
                      },
                      child: Text(
                        'Quên mật khẩu?',
                        style: TextStyle(
                          fontSize: 16,
                          color: _isHovering
                              ? AppPallete.secondaryColor
                              : AppPallete.primaryColor,
                          decoration: TextDecoration.underline,
                          decorationColor: _isHovering
                              ? AppPallete.secondaryColor
                              : AppPallete.primaryColor,
                        ),
                      ),
                    ),
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
