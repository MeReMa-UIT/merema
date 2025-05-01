import 'package:flutter/material.dart';
import 'package:merema/features/auth/presentation/pages/verification_code_page.dart';
import 'package:merema/features/auth/presentation/widgets/auth_button.dart';
import 'package:merema/features/auth/presentation/widgets/auth_field.dart';
import 'package:merema/features/auth/presentation/widgets/auth_layout.dart';

class ForgotPasswordPage extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const ForgotPasswordPage(),
      );
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final usernameController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    usernameController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    // TODO: Implement forgot password logic

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerificationCodePage(
          username: usernameController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      showBackButton: true,
      children: [
        const Text(
          'Quên mật khẩu',
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
        const SizedBox(height: 25),
        AuthButton(
          text: 'Tiếp theo',
          onPressed: _onNextPressed,
        ),
      ],
    );
  }
}
