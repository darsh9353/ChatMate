import 'package:flutter_bloc/flutter_bloc.dart';
import 'settings_event.dart';
import 'settings_state.dart';
import 'package:flutter/material.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsState.initial()) {
    on<ToggleThemeEvent>((event, emit) {
      emit(
        state.copyWith(
          themeMode: event.isDark ? ThemeMode.dark : ThemeMode.light,
        ),
      );
    });

    on<SetThemeEvent>((event, emit) {
      emit(state.copyWith(themeMode: event.themeMode));
    });
  }
}
