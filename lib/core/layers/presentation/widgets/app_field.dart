import 'package:flutter/material.dart';
import 'package:merema/core/theme/app_pallete.dart';

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
      return 'Please enter $hintText';
    }

    final asciiRegex = RegExp(r'^[\x00-\x7F]*$');
    if (!asciiRegex.hasMatch(value)) {
      return 'Please enter only ASCII characters for $hintText';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: hintText,
        labelStyle: const TextStyle(color: AppPallete.textColor),
      ),
      validator: validator ?? _defaultValidator,
      obscureText: isPassword,
    );
  }
}
