import 'package:flutter/material.dart';
import 'package:merema/features/auth/presentation/pages/login_page.dart';
import 'package:merema/features/auth/presentation/widgets/auth_button.dart';
import 'package:merema/features/auth/presentation/widgets/auth_field.dart';
import 'package:merema/features/auth/presentation/widgets/auth_layout.dart';

class ResetPasswordPage extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const ResetPasswordPage(),
      );

  const ResetPasswordPage({
    super.key,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _onResetPasswordPressed() {
    if (formKey.currentState?.validate() ?? false) {
      debugPrint('Reset password button pressed');
      // TODO: Implement password reset logic

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đặt lại mật khẩu thành công')),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formKey,
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
              controller: newPasswordController,
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
              controller: confirmPasswordController,
              isPassword: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập lại mật khẩu';
                }
                if (value != newPasswordController.text) {
                  return 'Mật khẩu không khớp';
                }
                return null;
              },
            ),
            const SizedBox(height: 25),
            AuthButton(
              text: 'Đặt lại mật khẩu',
              onPressed: _onResetPasswordPressed,
            ),
          ],
        ),
      ),
    );
  }
}
