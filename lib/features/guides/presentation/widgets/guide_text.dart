import 'package:flutter/material.dart';

import 'package:tc_flutter_web/core/theme/app_colors.dart';

/// A standard body paragraph inside a guide page.
class GuideParagraph extends StatelessWidget {
  /// Creates a guide paragraph.
  const GuideParagraph(this.text, {super.key});

  /// Paragraph text.
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.secondaryText,
        fontSize: 16,
        height: 1.55,
      ),
    );
  }
}

/// A small bold subheading inside a guide panel.
class GuideSubheading extends StatelessWidget {
  /// Creates a guide subheading.
  const GuideSubheading(this.text, {super.key});

  /// Subheading text.
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.primaryText,
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
