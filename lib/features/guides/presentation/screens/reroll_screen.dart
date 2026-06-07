import 'package:flutter/material.dart';

import 'package:tc_flutter_web/core/router/app_routes.dart';
import 'package:tc_flutter_web/core/widgets/flexible_card_grid.dart';
import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import '../widgets/guide_kit.dart';
import '../widgets/hero_portrait_card.dart';

/// The reroll guide page: the goal, the reroll loop as a stepper, the starter
/// carry targets as hero cards, and the common mistakes as a warning.
class RerollScreen extends StatelessWidget {
  /// Creates the reroll screen.
  const RerollScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return GuideScaffold(
      title: t.rerollTitle,
      children: [
        GuideCallout(
          variant: GuideCalloutVariant.info,
          title: t.rerollGoalTitle,
          text: t.rerollGoalText,
        ),
        GuidePanel(
          title: t.rerollLoopTitle,
          child: GuideStepper(
            steps: [
              t.rerollLoopOne,
              t.rerollLoopTwo,
              t.rerollLoopThree,
              t.rerollLoopFour,
              t.rerollLoopFive,
            ],
          ),
        ),
        GuidePanel(
          title: t.rerollTargetsTitle,
          body: t.rerollTargetsText,
          child: FlexibleCardGrid(
            minTileWidth: 220,
            children: [
              HeroPortraitCard(
                name: 'Renais',
                role: t.roleStarterCarry,
                description: t.heroRenaisDesc,
                image: 'assets/img/heroes/renais/profile.png',
                route: AppRoutes.starterCarry,
              ),
              HeroPortraitCard(
                name: 'Adele',
                role: t.roleStarterCarry,
                description: t.heroAdeleDesc,
                image: 'assets/img/heroes/adele/profile.png',
                route: AppRoutes.starterCarry,
              ),
              HeroPortraitCard(
                name: 'Ling',
                role: t.roleStarterCarry,
                description: t.heroLingDesc,
                image: 'assets/img/heroes/ling/profile.png',
                route: AppRoutes.starterCarry,
              ),
            ],
          ),
        ),
        GuideCallout(
          variant: GuideCalloutVariant.warning,
          title: t.rerollDontTitle,
          child: BulletGuideList(
            items: [
              t.rerollDontOne,
              t.rerollDontTwo,
              t.rerollDontThree,
              t.rerollDontFour,
            ],
          ),
        ),
      ],
    );
  }
}
