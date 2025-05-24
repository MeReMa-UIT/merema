import 'package:flutter/material.dart';
import 'package:merema/core/theme/app_pallete.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double width;
  final bool showShadow;
  final bool isLoading;
  final bool isWaiting;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.width = double.infinity,
    this.showShadow = true,
    this.isLoading = false,
    this.isWaiting = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _loading(context);
    }

    if (isWaiting) {
      return _waiting(context);
    }

    return _initial(context);
  }

  BoxDecoration? _getShadowDecoration() {
    if (!showShadow) return null;

    return BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: AppPallete.blackColor.withAlpha(25),
          spreadRadius: 0,
          blurRadius: 10.0,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  Widget _initial(BuildContext context) {
    return Container(
      width: width,
      height: 50,
      decoration: _getShadowDecoration(),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppPallete.primaryColor,
          foregroundColor: AppPallete.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: showShadow ? 3 : 0,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppPallete.textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _loading(BuildContext context) {
    return Container(
      width: width,
      height: 50,
      decoration: _getShadowDecoration(),
      child: ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppPallete.primaryColor,
          foregroundColor: AppPallete.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: showShadow ? 3 : 0,
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: AppPallete.backgroundColor,
          ),
        ),
      ),
    );
  }

  Widget _waiting(BuildContext context) {
    return Container(
      width: width,
      height: 50,
      decoration: _getShadowDecoration(),
      child: ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppPallete.lightGrayColor,
          foregroundColor: AppPallete.darkGrayColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: showShadow ? 3 : 0,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppPallete.darkGrayColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
