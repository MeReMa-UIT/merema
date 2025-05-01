import 'package:flutter/material.dart';
import 'package:merema/features/auth/presentation/pages/reset_password_page.dart';
import 'package:merema/features/auth/presentation/widgets/auth_button.dart';
import 'package:merema/features/auth/presentation/widgets/auth_field.dart';
import 'package:merema/features/auth/presentation/widgets/auth_layout.dart';

class VerificationCodePage extends StatefulWidget {
  static route({required String username}) => MaterialPageRoute(
        builder: (context) => VerificationCodePage(username: username),
      );

  final String username;

  const VerificationCodePage({
    super.key,
    required this.username,
  });

  @override
  State<VerificationCodePage> createState() => _VerificationCodePageState();
}

class _VerificationCodePageState extends State<VerificationCodePage> {
  final verificationCodeController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool _isResendDisabled = false;
  int _countdownSeconds = 30;

  @override
  void dispose() {
    verificationCodeController.dispose();
    super.dispose();
  }

  void _startResendCountdown() {
    setState(() {
      _isResendDisabled = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _countdownSeconds -= 1;
        });

        if (_countdownSeconds > 0) {
          _startResendCountdown();
        } else {
          setState(() {
            _isResendDisabled = false;
            _countdownSeconds = 30;
          });
        }
      }
    });
  }

  void _resendCode() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã gửi mã xác minh')),
    );

    _startResendCountdown();
  }

  void _onNextPressed() {
    if (formKey.currentState?.validate() ?? false) {
      // TODO: Implement verification logic
      bool isCodeValid = true;

      if (isCodeValid) {
        Navigator.push(
          context,
          ResetPasswordPage.route(),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mã xác minh không hợp lệ')),
        );
      }
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
              'Nhập mã xác minh',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 25),
            Text(
              'Mã xác minh đã được gửi đến người dùng ${widget.username}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AuthField(
                    hintText: 'Mã xác minh',
                    controller: verificationCodeController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mã xác minh';
                      }
                      if (value.length != 6 ||
                          !RegExp(r'^\d+$').hasMatch(value)) {
                        return 'Mã xác minh phải có 6 số';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 65,
                  child: AuthButton(
                    onPressed: _isResendDisabled ? null : _resendCode,
                    text: _isResendDisabled
                        ? 'Gửi lại ($_countdownSeconds)'
                        : 'Gửi lại',
                    width: 115,
                    showShadow: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            AuthButton(
              text: 'Tiếp theo',
              onPressed: _onNextPressed,
            ),
          ],
        ),
      ),
    );
  }
}
