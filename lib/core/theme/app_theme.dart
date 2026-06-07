import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Builds the application [ThemeData]. Kept in one place so screens never
/// hard-code colors or typography.
abstract final class AppTheme {
  /// The dark theme used across the whole app.
  static ThemeData get dark => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          brightness: Brightness.dark,
        ),
        fontFamily: 'Arial',
        scaffoldBackgroundColor: AppColors.pageBackground,
        useMaterial3: true,
      );
}
