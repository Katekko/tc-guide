import 'package:flutter/material.dart';

import 'package:tc_flutter_web/core/theme/app_colors.dart';
import 'package:tc_flutter_web/core/widgets/card_link.dart';

/// A simple title + description tile linking to another guide [route]. Used for
/// "Next Steps" style cross-links inside guide pages.
class GuideLinkCard extends StatelessWidget {
  /// Creates a guide link card.
  const GuideLinkCard({
    required this.title,
    required this.text,
    required this.route,
    super.key,
  });

  /// Card heading.
  final String title;

  /// Supporting description.
  final String text;

  /// Target in-app route.
  final String route;

  @override
  Widget build(BuildContext context) {
    return CardLink(
      route: route,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              text,
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 15,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
