import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tc_flutter_web/core/theme/app_colors.dart';
import 'package:tc_flutter_web/features/guides/domain/entities/guide_nav.dart';
import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import 'guide_status_badge.dart';

/// A guide-index card for one [GuideNavSection]: a heading with a guide count
/// followed by a tappable row per guide, each carrying a freshness badge.
class GuideCategoryCard extends StatelessWidget {
  /// Creates a category card for [section].
  const GuideCategoryCard({required this.section, super.key});

  /// The navigation section this card represents.
  final GuideNavSection section;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    section.title,
                    style: const TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  t.guideCountLabel(section.items.length),
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final item in section.items) _GuideRow(item: item),
          ],
        ),
      ),
    );
  }
}

/// A single tappable guide row inside a [GuideCategoryCard].
class _GuideRow extends StatelessWidget {
  const _GuideRow({required this.item});

  final GuideNavItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(item.route),
      borderRadius: BorderRadius.circular(6),
      hoverColor: AppColors.selectedBackground,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
        child: Row(
          children: [
            Expanded(
              child: Text(
                item.title,
                style: const TextStyle(
                  color: AppColors.link,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 10),
            GuideStatusBadge(status: item.status),
          ],
        ),
      ),
    );
  }
}
