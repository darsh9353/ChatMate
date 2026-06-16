import 'package:flutter_bloc/flutter_bloc.dart';
import 'language_event.dart';
import 'language_state.dart';
import 'package:flutter/material.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  LanguageBloc() : super(LanguageState(locale: const Locale('en'))) {
    on<ChangeLanguageEvent>((event, emit) {
      emit(LanguageState(locale: event.locale));
    });
  }
}
