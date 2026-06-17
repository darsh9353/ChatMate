import 'package:flutter/material.dart';

abstract class SettingsEvent {}

class ToggleThemeEvent extends SettingsEvent {
  final bool isDark;

  ToggleThemeEvent(this.isDark);
}

class SetThemeEvent extends SettingsEvent {
  final ThemeMode themeMode;

  SetThemeEvent(this.themeMode);
}

class LoadThemeEvent extends SettingsEvent {}
