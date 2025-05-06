import 'package:flutter/material.dart';
import 'package:merema/core/utils/service_locator.dart';
import 'package:merema/features/auth/domain/usecases/recovery.dart';
import 'package:merema/features/auth/presentation/pages/reset_password_page.dart';
import 'package:merema/features/auth/presentation/widgets/auth_button.dart';
import 'package:merema/features/auth/presentation/widgets/auth_field.dart';
import 'package:merema/features/auth/presentation/widgets/auth_layout.dart';
import 'package:merema/features/auth/data/models/auth_req_params.dart';

class VerificationCodePage extends StatefulWidget {
  static route({required String token, required String email}) =>
      MaterialPageRoute(
        builder: (context) => VerificationCodePage(token: token, email: email),
      );

  final String token;
  final String email;

  const VerificationCodePage({
    super.key,
    required this.token,
    required this.email,
  });

  @override
  State<VerificationCodePage> createState() => _VerificationCodePageState();
}

class _VerificationCodePageState extends State<VerificationCodePage> {
  final _verificationCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isResendDisabled = false;
  int _countdownSeconds = 30;

  @override
  void dispose() {
    _verificationCodeController.dispose();
    super.dispose();
  }

  Future<void> _onNextPressed() async {
    if (_formKey.currentState?.validate() ?? false) {
      final result = await sl<RecoveryConfirmUseCase>().call(
        RecoveryConfirmReqParams(
          token: widget.token,
          otp: _verificationCodeController.text,
        ),
      );

      result.fold((failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
          // TODO: Handle confirmation status
          (success) {
        if (success == 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Xác minh thành công')),
          );
          Navigator.push(
            context,
            ResetPasswordPage.route(token: widget.token, email: widget.email),
          );
        } else {
          debugPrint('Xác minh không thành công');
        }
      });
    }
  }

  void _resendCode() {
    // TODO: Implement resend code logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã gửi mã xác minh')),
    );

    _startResendCountdown();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
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
              'Mã xác minh đã được gửi đến email ${widget.email}',
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
                    controller: _verificationCodeController,
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
