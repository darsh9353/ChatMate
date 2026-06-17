import 'package:flutter_bloc/flutter_bloc.dart';
import 'settings_event.dart';
import 'settings_state.dart';
import 'package:flutter/material.dart';
import 'package:chatmate/services/theme_service.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsState.initial()) {
    on<ToggleThemeEvent>((event, emit) async {
      final mode = event.isDark ? ThemeMode.dark : ThemeMode.light;

      await ThemeService.saveTheme(mode); // SAVE

      emit(state.copyWith(themeMode: mode));
    });

    on<SetThemeEvent>((event, emit) async {
      await ThemeService.saveTheme(event.themeMode); // SAVE

      emit(state.copyWith(themeMode: event.themeMode));
    });

    on<LoadThemeEvent>((event, emit) async {
      final mode = await ThemeService.loadTheme();
      emit(state.copyWith(themeMode: mode));
    });
    add(LoadThemeEvent());
  }
}
