import 'package:flutter/material.dart';

class AuthField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool isPassword;
  final String? Function(String?)? validator;

  const AuthField({
    super.key,
    required this.hintText,
    required this.controller,
    this.isPassword = false,
    this.validator,
  });

  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập $hintText';
    }

    bool isAscii = true;
    if (value.isNotEmpty) {
      for (int i = 0; i < value.length; i++) {
        if (value.codeUnitAt(i) > 127) {
          isAscii = false;
          break;
        }
      }
    }

    if (!isAscii) {
      return 'Vui lòng chỉ nhập ký tự ASCII cho $hintText';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
      ),
      validator: validator ?? _defaultValidator,
      obscureText: isPassword,
      obscuringCharacter: '*',
    );
  }
}
