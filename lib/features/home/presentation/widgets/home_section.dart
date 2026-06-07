import 'package:flutter/material.dart';

import 'package:tc_flutter_web/core/theme/app_colors.dart';

/// Visual tone of a [HomeSection] band.
enum SectionTone {
  /// Default section background.
  plain,

  /// Slightly lighter alternate background.
  subtle,
}

/// A titled content band on the home screen with a constrained, centered body.
class HomeSection extends StatelessWidget {
  /// Creates a home section.
  const HomeSection({
    required this.title,
    required this.subtitle,
    required this.child,
    this.tone = SectionTone.plain,
    super.key,
  });

  /// Section heading.
  final String title;

  /// Section supporting text.
  final String subtitle;

  /// Section body.
  final Widget child;

  /// Background tone.
  final SectionTone tone;

  @override
  Widget build(BuildContext context) {
    final background = tone == SectionTone.subtle
        ? AppColors.sectionAltBackground
        : AppColors.sectionBackground;

    return ColoredBox(
      color: background,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1160),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.primaryText,
                          fontSize: 30,
                          height: 1.15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 16,
                          height: 1.55,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
