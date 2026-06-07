import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';

/// Holds the user-selected app [Locale] and drives `MaterialApp.locale`.
///
/// This is the app's one genuinely stateful concern, so it is the showcase use
/// of `flutter_bloc` (see AGENTS.md). Locale is a simple value, so a [Cubit] of
/// [Locale] is used rather than a sealed loading/loaded state machine.
class LocaleCubit extends Cubit<Locale> {
  /// Creates the cubit, defaulting to English.
  LocaleCubit() : super(const Locale('en'));

  /// Selects [locale] as the active app locale.
  void select(Locale locale) => emit(locale);
}
