import 'package:flutter/material.dart';

import 'package:tc_flutter_web/core/theme/app_colors.dart';

/// A thin attribution / note band at the bottom of the home screen.
class NoteBand extends StatelessWidget {
  /// Creates a note band showing [text].
  const NoteBand({required this.text, super.key});

  /// The note content.
  final String text;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.sectionAltBackground,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1160),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
