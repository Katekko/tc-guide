import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/locale/locale_cubit.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'l10n/generated/app_localizations.dart';

/// Root application widget. Provides the [LocaleCubit] and rebuilds
/// `MaterialApp.router` whenever the active locale changes.
class App extends StatelessWidget {
  /// Creates the app, building the router once so navigation state survives
  /// locale changes.
  App({super.key}) : _router = buildRouter();

  final GoRouter _router;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LocaleCubit(),
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Twilight Chronicle Guides',
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.dark,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
