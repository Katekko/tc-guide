import 'package:tc_flutter_web/core/router/app_routes.dart';
import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import '../../domain/entities/hero_item.dart';
import '../../domain/entities/link_item.dart';
import '../../domain/repositories/home_repository.dart';

/// [HomeRepository] backed by the app's localized strings.
class HomeRepositoryImpl implements HomeRepository {
  /// Creates the localized home repository.
  const HomeRepositoryImpl();

  @override
  List<LinkItem> starterPath(AppLocalizations l10n) => [
        LinkItem(
          title: l10n.starterRerollTitle,
          text: l10n.starterRerollText,
          route: AppRoutes.reroll,
        ),
        LinkItem(
          title: l10n.starterCarryTitle,
          text: l10n.starterCarryText,
          route: AppRoutes.starterCarry,
        ),
        LinkItem(
          title: l10n.starterSpendTitle,
          text: l10n.starterSpendText,
          route: AppRoutes.shopPriority,
        ),
        LinkItem(
          title: l10n.starterUrTitle,
          text: l10n.starterUrText,
          route: AppRoutes.urPriority,
        ),
      ];

  @override
  List<HeroItem> featuredHeroes(AppLocalizations l10n) => [
        HeroItem(
          name: 'Renais',
          role: l10n.roleStarterCarry,
          image: 'assets/img/heroes/renais/profile.png',
          route: AppRoutes.heroPath('renais'),
        ),
        HeroItem(
          name: 'Adele',
          role: l10n.roleStarterCarry,
          image: 'assets/img/heroes/adele/profile.png',
          route: AppRoutes.heroPath('adele'),
        ),
        HeroItem(
          name: 'Ling',
          role: l10n.roleStarterCarry,
          image: 'assets/img/heroes/ling/profile.png',
          route: AppRoutes.heroPath('ling'),
        ),
        HeroItem(
          name: 'Jeanne',
          role: l10n.roleUrGuide,
          image: 'assets/img/heroes/jeanne/profile.png',
          route: AppRoutes.heroPath('jeanne'),
        ),
      ];

  @override
  List<LinkItem> guideSections(AppLocalizations l10n) => [
        LinkItem(
          title: l10n.guideGettingStartedTitle,
          text: l10n.guideGettingStartedText,
          route: AppRoutes.gettingStarted,
        ),
        LinkItem(
          title: l10n.guideResourcesTitle,
          text: l10n.guideResourcesText,
          route: AppRoutes.shopPriority,
        ),
        LinkItem(
          title: l10n.guideUrTitle,
          text: l10n.guideUrText,
          route: AppRoutes.urIntroduction,
        ),
        LinkItem(
          title: l10n.guideGearTitle,
          text: l10n.guideGearText,
          route: AppRoutes.stats,
        ),
        LinkItem(
          title: l10n.guideBeastTitle,
          text: l10n.guideBeastText,
          route: AppRoutes.soulMirrors,
        ),
        LinkItem(
          title: l10n.guideTeamTitle,
          text: l10n.guideTeamText,
          route: AppRoutes.teamComps,
        ),
      ];
}
