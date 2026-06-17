import 'package:flutter/material.dart';

class SettingsState {
  final ThemeMode themeMode;

  SettingsState({required this.themeMode});

  factory SettingsState.initial() {
    return SettingsState(
      themeMode: ThemeMode.system, // temporary
    );
  }

  SettingsState copyWith({ThemeMode? themeMode}) {
    return SettingsState(themeMode: themeMode ?? this.themeMode);
  }
}
