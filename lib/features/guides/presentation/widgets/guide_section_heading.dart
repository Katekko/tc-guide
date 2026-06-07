import 'package:flutter/material.dart';

import 'package:tc_flutter_web/core/theme/app_colors.dart';

/// A lightweight heading (title + optional subtitle) introducing a block of
/// content on the guide index, without the bordered surface of a panel.
class GuideSectionHeading extends StatelessWidget {
  /// Creates a section heading.
  const GuideSectionHeading({required this.title, this.subtitle, super.key});

  /// The heading text.
  final String title;

  /// Optional supporting line below the title.
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.primaryText,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 15,
              height: 1.45,
            ),
          ),
        ],
      ],
    );
  }
}
