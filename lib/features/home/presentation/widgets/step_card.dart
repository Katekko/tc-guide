import 'package:flutter/material.dart';

import 'package:tc_flutter_web/core/theme/app_colors.dart';
import 'package:tc_flutter_web/core/widgets/card_link.dart';

import '../../domain/entities/link_item.dart';

/// A numbered step tile used in the "Recommended Start" grid.
class StepCard extends StatelessWidget {
  /// Creates a step card for [item] showing [number].
  const StepCard({required this.number, required this.item, super.key});

  /// 1-based step number shown in the badge.
  final int number;

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
            DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: SizedBox(
                width: 34,
                height: 34,
                child: Center(
                  child: Text(
                    '$number',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              item.title,
              style: const TextStyle(
                color: AppColors.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
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
