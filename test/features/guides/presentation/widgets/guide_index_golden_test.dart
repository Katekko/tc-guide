import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:tc_flutter_web/core/theme/app_colors.dart';
import 'package:tc_flutter_web/features/guides/domain/entities/guide_nav.dart';
import 'package:tc_flutter_web/features/guides/domain/entities/guide_status.dart';
import 'package:tc_flutter_web/features/guides/domain/entities/guide_step.dart';
import 'package:tc_flutter_web/features/guides/presentation/widgets/guide_category_card.dart';
import 'package:tc_flutter_web/features/guides/presentation/widgets/guide_status_badge.dart';
import 'package:tc_flutter_web/features/guides/presentation/widgets/guide_step_card.dart';
import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

/// Wraps a scenario child with the inherited widgets the index pieces need:
/// directionality, localizations, and a [Material] ancestor for [InkWell].
Widget _host(Widget child) => Directionality(
      textDirection: TextDirection.ltr,
      child: Localizations(
        locale: const Locale('en'),
        delegates: AppLocalizations.localizationsDelegates,
        child: Material(color: AppColors.pageBackground, child: child),
      ),
    );

void main() {
  goldenTest(
    'guide index renders badges, step and category cards',
    fileName: 'guide_index',
    builder: () => GoldenTestGroup(
      columnWidthBuilder: (_) => const FixedColumnWidth(380),
      children: [
        GoldenTestScenario(
          name: 'status badges',
          child: _host(
            const Padding(
              padding: EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  GuideStatusBadge(status: GuideStatus.draft),
                  GuideStatusBadge(status: GuideStatus.needsReview),
                  GuideStatusBadge(status: GuideStatus.current),
                  GuideStatusBadge(status: GuideStatus.outdated),
                ],
              ),
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'step card',
          child: _host(
            const Padding(
              padding: EdgeInsets.all(12),
              child: GuideStepCard(
                number: 1,
                step: GuideStep(
                  title: 'Reroll',
                  text: 'Start with a strong carry instead of fixing the '
                      'account for weeks.',
                  route: '/docs/reroll',
                ),
              ),
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'category card',
          child: _host(
            const Padding(
              padding: EdgeInsets.all(12),
              child: GuideCategoryCard(
                section: GuideNavSection(
                  title: 'Getting Started',
                  items: [
                    GuideNavItem(
                      title: 'Getting Started',
                      route: '/docs/getting-started',
                    ),
                    GuideNavItem(
                      title: 'Reroll',
                      route: '/docs/reroll',
                      status: GuideStatus.current,
                    ),
                    GuideNavItem(
                      title: 'Starter Carry Route',
                      route: '/docs/starter-carry',
                      status: GuideStatus.needsReview,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
