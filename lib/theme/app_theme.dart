import 'package:flutter/material.dart';

class AppTheme {
  // LIGHT THEME
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Colors.blue,
      onPrimary: Colors.white,

      secondary: Colors.grey,
      onSecondary: Colors.black,

      surface: Colors.white,
      onSurface: Colors.black,

      error: Colors.red,
      onError: Colors.white,
    ),
  );

  // DARK THEME
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: Colors.blue,
      onPrimary: Colors.white,

      secondary: Colors.white,
      onSecondary: Color(0xFF2C2C2C),

      surface: Colors.white,
      onSurface: Colors.black,

      error: Colors.red,
      onError: Colors.black,
    ),
  );
}
