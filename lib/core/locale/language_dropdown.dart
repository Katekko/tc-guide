import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tc_flutter_web/core/theme/app_colors.dart';

import 'locale_cubit.dart';

/// The languages the user can switch between.
const List<({Locale locale, String label})> _languages = [
  (locale: Locale('en'), label: 'English'),
  (locale: Locale('pt', 'BR'), label: 'Português (BR)'),
];

/// A compact language switcher backed by [LocaleCubit]. Restores the locale
/// dropdown the former Docusaurus navbar had.
class LanguageDropdown extends StatelessWidget {
  /// Creates the language dropdown.
  const LanguageDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final current = context.watch<LocaleCubit>().state;

    return PopupMenuButton<Locale>(
      tooltip: 'Language',
      onSelected: context.read<LocaleCubit>().select,
      itemBuilder: (context) => _languages
          .map(
            (lang) => PopupMenuItem<Locale>(
              value: lang.locale,
              child: Text(lang.label),
            ),
          )
          .toList(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, size: 18, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              _labelFor(current),
              style: const TextStyle(
                color: AppColors.primaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.white),
          ],
        ),
      ),
    );
  }

  String _labelFor(Locale locale) {
    for (final lang in _languages) {
      if (lang.locale.languageCode == locale.languageCode) return lang.label;
    }
    return _languages.first.label;
  }
}
