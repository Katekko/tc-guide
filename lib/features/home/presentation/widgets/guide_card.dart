import 'package:flutter/material.dart';

import 'package:tc_flutter_web/core/theme/app_colors.dart';
import 'package:tc_flutter_web/core/widgets/card_link.dart';

import '../../domain/entities/link_item.dart';

/// A title + description card linking to a guide section.
class GuideCard extends StatelessWidget {
  /// Creates a guide card for [item].
  const GuideCard({required this.item, super.key});

  /// The link content.
  final LinkItem item;

  @override
  Widget build(BuildContext context) {
    return CardLink(
      route: item.route,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title,
              style: const TextStyle(
                color: AppColors.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item.text,
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
