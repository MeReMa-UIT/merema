import 'package:flutter/material.dart';
import 'package:merema/core/utils/service_locator.dart';
import 'package:merema/features/auth/domain/usecases/recovery.dart';
import 'package:merema/features/auth/presentation/pages/verification_code_page.dart';
import 'package:merema/features/auth/presentation/widgets/auth_button.dart';
import 'package:merema/features/auth/presentation/widgets/auth_field.dart';
import 'package:merema/features/auth/presentation/widgets/auth_layout.dart';
import 'package:merema/features/auth/data/models/auth_req_params.dart';

class ForgotPasswordPage extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const ForgotPasswordPage(),
      );
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onNextPressed() async {
    if (_formKey.currentState?.validate() ?? false) {
      final result = await sl<RecoveryUseCase>().call(
        RecoveryReqParams(
          email: _emailController.text,
        ),
      );

      result.fold((failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      }, (token) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationCodePage(
              email: _emailController.text,
              token: token,
            ),
          ),
        );
      });
    }
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
        Form(
          key: _formKey,
          child: AuthField(
            hintText: 'Email',
            controller: _emailController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập email';
              }
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return 'Email không hợp lệ';
              }
              return null;
            },
          ),
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
