import 'package:flutter/material.dart';
import 'package:merema/core/theme/app_pallete.dart';

class AppTheme {
  static _border([Color color = AppPallete.primaryColor]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: color,
          width: 2,
        ),
      );
  static final lightThemeMode = ThemeData.light().copyWith(
    scaffoldBackgroundColor: AppPallete.backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPallete.backgroundColor,
      elevation: 0,
      iconTheme: IconThemeData(color: AppPallete.primaryColor),
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(24),
      enabledBorder: _border(),
      focusedBorder: _border(AppPallete.secondaryColor),
      errorBorder: _border(AppPallete.errorColor),
      focusedErrorBorder: _border(AppPallete.errorColor),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppPallete.textColor,
      selectionColor: AppPallete.lightGrayColor,
      selectionHandleColor: AppPallete.lightGrayColor,
    ),
  );
}
