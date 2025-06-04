import 'package:flutter/material.dart';
import 'package:merema/core/theme/app_pallete.dart';

class AppField extends StatelessWidget {
  final String labelText;
  final String? hintText;
  final TextEditingController controller;
  final bool isPassword;
  final String? Function(String?)? validator;
  final bool alwaysShowLabel;
  final bool required;

  const AppField({
    super.key,
    required this.labelText,
    this.hintText,
    required this.controller,
    this.isPassword = false,
    this.validator,
    this.alwaysShowLabel = false,
    this.required = true,
  });

  String? _defaultValidator(String? value) {
    if (required && (value == null || value.isEmpty)) {
      return 'Please enter $labelText';
    }
    if (value != null && value.isNotEmpty) {
      final asciiRegex = RegExp(r'^[\x00-\x7F]*$');
      if (!asciiRegex.hasMatch(value)) {
        return 'Please enter only ASCII characters for $labelText';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: const TextStyle(color: AppPallete.textColor),
        floatingLabelBehavior: alwaysShowLabel
            ? FloatingLabelBehavior.always
            : FloatingLabelBehavior.auto,
      ),
      validator: validator ?? _defaultValidator,
      obscureText: isPassword,
    );
  }
}
