import 'package:flutter/material.dart';

class AppField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool isPassword;
  final String? Function(String?)? validator;

  const AppField({
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

    final asciiRegex = RegExp(r'^[\x00-\x7F]*$');
    if (!asciiRegex.hasMatch(value)) {
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
    );
  }
}
