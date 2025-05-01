import 'package:flutter/material.dart';
import 'package:merema/core/theme/app_pallete.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double width;
  final bool showShadow;

  const AuthButton({
    super.key,
    required this.text,
    this.onPressed,
    this.width = double.infinity,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 50,
      decoration: showShadow
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppPallete.blackColor.withAlpha(25),
                  spreadRadius: 0,
                  blurRadius: 10.0,
                  offset: const Offset(0, 3),
                ),
              ],
            )
          : null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed == null
              ? AppPallete.lightGrayColor
              : AppPallete.primaryColor,
          foregroundColor: onPressed == null
              ? AppPallete.lightGrayColor
              : AppPallete.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: showShadow ? 3 : 0,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: onPressed == null
                ? AppPallete.darkGrayColor
                : AppPallete.backgroundColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
