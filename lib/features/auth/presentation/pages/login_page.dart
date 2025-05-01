import 'package:flutter/material.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:merema/features/auth/presentation/widgets/auth_button.dart';
import 'package:merema/features/auth/presentation/widgets/auth_field.dart';
import 'package:merema/features/auth/presentation/widgets/auth_layout.dart';

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
  bool _isHovering = false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    // TODO: Implement login logic and route to the main page

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đăng nhập thành công')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthLayout(
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
          AuthButton(
            text: 'Đăng nhập',
            onPressed: _onLoginPressed,
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
    );
  }
}
