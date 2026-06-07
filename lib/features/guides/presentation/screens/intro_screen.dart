import 'package:flutter/material.dart';

import 'package:tc_flutter_web/core/di/injection_container.dart';
import 'package:tc_flutter_web/core/theme/app_colors.dart';
import 'package:tc_flutter_web/core/widgets/flexible_card_grid.dart';
import 'package:tc_flutter_web/features/guides/domain/entities/guide_nav.dart';
import 'package:tc_flutter_web/features/guides/domain/entities/guide_status.dart';
import 'package:tc_flutter_web/features/guides/domain/repositories/guides_repository.dart';
import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import '../widgets/guide_category_card.dart';
import '../widgets/guide_kit.dart';
import '../widgets/guide_section_heading.dart';
import '../widgets/guide_status_badge.dart';
import '../widgets/guide_step_card.dart';

/// The top-level guide index: a "Start Here" path for newcomers, a browsable
/// grid of guide categories, and a key explaining the freshness badges.
class IntroScreen extends StatelessWidget {
  /// Creates the intro screen.
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final repository = sl<GuidesRepository>();
    final steps = repository.startHere(t);
    final sections =
        repository.navigation(t).whereType<GuideNavSection>().toList();

    return GuideScaffold(
      title: t.introTitle,
      intro: t.introIntro,
      children: [
        _Section(
          title: t.introStartHereTitle,
          subtitle: t.introStartHereText,
          child: FlexibleCardGrid(
            minTileWidth: 210,
            children: [
              for (final (index, step) in steps.indexed)
                GuideStepCard(number: index + 1, step: step),
            ],
          ),
        ),
        _Section(
          title: t.introBrowseTitle,
          subtitle: t.introBrowseText,
          child: FlexibleCardGrid(
            minTileWidth: 300,
            children: [
              for (final section in sections)
                GuideCategoryCard(section: section),
            ],
          ),
        ),
        const _StatusKey(),
      ],
    );
  }
}

/// A heading followed by its content block, kept tight together so the
/// surrounding [GuideContent] spacing separates whole sections.
class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GuideSectionHeading(title: title, subtitle: subtitle),
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}

/// The legend explaining what each freshness badge means.
class _StatusKey extends StatelessWidget {
  const _StatusKey();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final entries = <(GuideStatus, String)>[
      (GuideStatus.draft, t.introStatusDraft),
      (GuideStatus.needsReview, t.introStatusNeedsReview),
      (GuideStatus.current, t.introStatusCurrent),
      (GuideStatus.outdated, t.introStatusOutdated),
    ];

    return GuidePanel(
      title: t.introStatusKeyTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (index, entry) in entries.indexed) ...[
            if (index > 0) const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GuideStatusBadge(status: entry.$1),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.$2,
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
