import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class ThemeService {
  static const String key = "theme_mode";

  // SAVE THEME
  static Future<void> saveTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, mode.name); // light / dark / system
  }

  // LOAD THEME
  static Future<ThemeMode> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(key);

    if (value == null) return ThemeMode.system;

    return ThemeMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ThemeMode.system,
    );
  }
}
