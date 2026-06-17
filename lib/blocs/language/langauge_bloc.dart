import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'language_event.dart';
import 'language_state.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  LanguageBloc() : super(LanguageState(locale: const Locale('en'))) {
    //  Load saved language properly via event
    on<LoadLanguageEvent>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString('language_code');

      emit(
        LanguageState(locale: code != null ? Locale(code) : const Locale('en')),
      );
    });

    //  Change + Save
    on<ChangeLanguageEvent>((event, emit) async {
      emit(LanguageState(locale: event.locale));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', event.locale.languageCode);
    });
  }
}
