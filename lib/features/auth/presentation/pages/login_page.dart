import 'package:flutter/material.dart';
import 'package:merema/core/theme/app_pallete.dart';
//import 'package:merema/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:merema/features/auth/presentation/widgets/auth_button.dart';
import 'package:merema/features/auth/presentation/widgets/auth_field.dart';

class LoginPage extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const LoginPage(),
      );
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  static const double fieldWidth = 400;
  static const double minSidePadding = 24.0;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;

          final contentWidth =
              availableWidth > (fieldWidth + 2 * minSidePadding)
                  ? fieldWidth
                  : availableWidth - 2 * minSidePadding;

          return Center(
            child: SizedBox(
              width: contentWidth,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                      hintText: 'Tên đăng nhập',
                      controller: usernameController,
                    ),
                    const SizedBox(height: 15),
                    AuthField(
                      hintText: 'Mật khẩu',
                      controller: passwordController,
                      isPassword: true,
                    ),
                    const SizedBox(height: 25),
                    const AuthButton(text: 'Đăng nhập'),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        //Navigator.push(context, ForgotPasswordPage.route());
                      },
                      child: const Text(
                        'Quên mật khẩu?',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppPallete.primaryColor,
                        ),
                      ),
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
