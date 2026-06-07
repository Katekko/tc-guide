import 'package:flutter/material.dart';

import 'package:tc_flutter_web/core/theme/app_colors.dart';

/// The header band at the top of a guide page (eyebrow, title, intro).
class GuideHeader extends StatelessWidget {
  /// Creates a guide header.
  const GuideHeader({
    required this.title,
    this.eyebrow,
    this.intro,
    super.key,
  });

  /// Page title.
  final String title;

  /// Optional small kicker above the title.
  final String? eyebrow;

  /// Optional intro paragraph below the title.
  final String? intro;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.pageBackground,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 46, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (eyebrow != null) ...[
                  Text(
                    eyebrow!.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.eyebrow,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 44,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (intro != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    intro!,
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 18,
                      height: 1.55,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The constrained, centered content column below a [GuideHeader]. Each child
/// is spaced vertically.
class GuideContent extends StatelessWidget {
  /// Creates a guide content column.
  const GuideContent({required this.children, super.key});

  /// The content blocks.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.sectionBackground,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 64),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children
                  .map(
                    (child) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: child,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
