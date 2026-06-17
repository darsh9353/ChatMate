import 'package:flutter/material.dart';

class AppTheme {
  //  LIGHT THEME
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F7FB),

    colorScheme: const ColorScheme(
      brightness: Brightness.light,

      primary: Colors.blue,
      onPrimary: Colors.white,

      secondary: Color(0xFFE9EEF6),
      onSecondary: Colors.black87,

      surface: Colors.white,
      onSurface: Color(0xFF1A1A1A),

      error: Colors.red,
      onError: Colors.white,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),

    cardColor: Colors.white,

    dividerColor: Color(0xFFE0E0E0),
  );

  //  DARK THEME
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0F172A),

    colorScheme: const ColorScheme(
      brightness: Brightness.dark,

      primary: Colors.blue,
      onPrimary: Colors.white,

      secondary: Color(0xFF1E293B),
      onSecondary: Colors.white,

      surface: Color(0xFF111827),
      onSurface: Color(0xFFE5E7EB),

      error: Colors.red,
      onError: Colors.black,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),

    cardColor: Color(0xFF1F2937),

    dividerColor: Color(0xFF374151),
  );

  //  LIGHT BACKGROUND GRADIENT
  static const List<Color> lightGradient = [
    Color(0xFFE8F0EF),
    Color(0xFFB0D4CE),
  ];

  //  DARK BACKGROUND GRADIENT
  static const List<Color> darkGradient = [
    Color.fromARGB(255, 41, 45, 77),
    Color.fromARGB(169, 104, 158, 146),
  ];
}
