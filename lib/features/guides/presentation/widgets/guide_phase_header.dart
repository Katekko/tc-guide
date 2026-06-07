import 'package:flutter/material.dart';

import 'package:tc_flutter_web/core/theme/app_colors.dart';

/// A numbered phase divider for the new-player journey: a prominent step number
/// beside a title and subtitle, marking the start of a progression phase.
class GuidePhaseHeader extends StatelessWidget {
  /// Creates a phase header.
  const GuidePhaseHeader({
    required this.number,
    required this.title,
    required this.subtitle,
    super.key,
  });

  /// 1-based phase number shown in the marker.
  final int number;

  /// Phase title.
  final String title;

  /// Supporting line below the title.
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.16),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accent, width: 2),
            ),
            child: SizedBox(
              width: 46,
              height: 46,
              child: Center(
                child: Text(
                  '$number',
                  style: const TextStyle(
                    color: AppColors.link,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
