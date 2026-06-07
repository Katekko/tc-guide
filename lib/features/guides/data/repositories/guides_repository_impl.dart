import 'package:tc_flutter_web/core/router/app_routes.dart';
import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import '../../domain/entities/guide_nav.dart';
import '../../domain/entities/guide_step.dart';
import '../../domain/repositories/guides_repository.dart';

/// [GuidesRepository] backed by the app's localized strings. The structure
/// mirrors the former Docusaurus `tutorialSidebar`.
class GuidesRepositoryImpl implements GuidesRepository {
  /// Creates the localized guides repository.
  const GuidesRepositoryImpl();

  @override
  List<GuideNavEntry> navigation(AppLocalizations l10n) => [
        GuideNavLink(title: l10n.navGuideIndex, route: AppRoutes.intro),
        GuideNavSection(
          title: l10n.navSectionGettingStarted,
          items: [
            GuideNavItem(
              title: l10n.navGettingStarted,
              route: AppRoutes.gettingStarted,
            ),
            GuideNavItem(title: l10n.navReroll, route: AppRoutes.reroll),
            GuideNavItem(
              title: l10n.navStarterCarry,
              route: AppRoutes.starterCarry,
            ),
          ],
        ),
        GuideNavSection(
          title: l10n.navSectionResources,
          items: [
            GuideNavItem(
              title: l10n.navShopPriority,
              route: AppRoutes.shopPriority,
            ),
            GuideNavItem(title: l10n.navSpending, route: AppRoutes.spending),
          ],
        ),
        GuideNavSection(
          title: l10n.navSectionUr,
          items: [
            GuideNavItem(
              title: l10n.navUrIntroduction,
              route: AppRoutes.urIntroduction,
            ),
            GuideNavItem(title: l10n.navUrPriority, route: AppRoutes.urPriority),
            GuideNavItem(title: l10n.navUrPlus, route: AppRoutes.urPlus),
            GuideNavItem(title: l10n.navJeanne, route: AppRoutes.jeanne),
          ],
        ),
        GuideNavSection(
          title: l10n.navSectionUrPlus,
          items: [
            GuideNavItem(title: l10n.navNyx, route: AppRoutes.nyx),
          ],
        ),
        GuideNavSection(
          title: l10n.navSectionGears,
          items: [
            GuideNavItem(title: l10n.navStats, route: AppRoutes.stats),
            GuideNavItem(title: l10n.navGears, route: AppRoutes.gears),
          ],
        ),
        GuideNavSection(
          title: l10n.navSectionBeast,
          items: [
            GuideNavItem(
              title: l10n.navSoulMirrors,
              route: AppRoutes.soulMirrors,
            ),
          ],
        ),
        GuideNavSection(
          title: l10n.navSectionTeam,
          items: [
            GuideNavItem(title: l10n.navTeamComps, route: AppRoutes.teamComps),
            GuideNavItem(title: l10n.navTierList, route: AppRoutes.tierList),
          ],
        ),
      ];

  @override
  List<GuideNavItem> flatItems(AppLocalizations l10n) {
    final items = <GuideNavItem>[];
    for (final entry in navigation(l10n)) {
      switch (entry) {
        case GuideNavLink():
          items.add(GuideNavItem(title: entry.title, route: entry.route));
        case GuideNavSection():
          items.addAll(entry.items);
      }
    }
    return items;
  }

  @override
  String titleForRoute(AppLocalizations l10n, String route) {
    for (final item in flatItems(l10n)) {
      if (item.route == route) return item.title;
    }
    return route;
  }

  @override
  List<GuideStep> startHere(AppLocalizations l10n) => [
        GuideStep(
          title: l10n.starterRerollTitle,
          text: l10n.starterRerollText,
          route: AppRoutes.reroll,
        ),
        GuideStep(
          title: l10n.starterCarryTitle,
          text: l10n.starterCarryText,
          route: AppRoutes.starterCarry,
        ),
        GuideStep(
          title: l10n.starterSpendTitle,
          text: l10n.starterSpendText,
          route: AppRoutes.shopPriority,
        ),
        GuideStep(
          title: l10n.starterUrTitle,
          text: l10n.starterUrText,
          route: AppRoutes.urPriority,
        ),
      ];
}
