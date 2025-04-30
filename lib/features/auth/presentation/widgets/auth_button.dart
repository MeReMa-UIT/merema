import 'package:flutter/material.dart';
import 'package:merema/core/theme/app_pallete.dart';

class AuthButton extends StatelessWidget {
  final String text;
  const AuthButton({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(400, 50),
        backgroundColor: AppPallete.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppPallete.backgroundColor),
      ),
    );
  }
}
