import 'package:flutter/material.dart';

import 'package:tc_flutter_web/core/router/app_routes.dart';
import 'package:tc_flutter_web/core/widgets/flexible_card_grid.dart';
import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import '../widgets/guide_kit.dart';
import '../widgets/hero_portrait_card.dart';
import '../widgets/hero_spine_spotlight.dart';

/// The "New Player Guide" — the flagship onboarding page, organized as a
/// three-phase journey (first session, first week, first month) and built
/// entirely from the guide widget kit with all text sourced from ARB.
class GettingStartedScreen extends StatelessWidget {
  /// Creates the getting started screen.
  const GettingStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return GuideScaffold(
      title: t.startHereTitle,
      eyebrow: t.startHereEyebrow,
      intro: t.startHereIntro,
      children: [
        // ── Phase 1 — Your First Session ────────────────────────────────
        GuidePhaseHeader(
          number: 1,
          title: t.phaseOneTitle,
          subtitle: t.phaseOneText,
        ),
        GuidePanel(
          title: t.quickStartTitle,
          child: GuideStepper(
            steps: [
              t.quickStartOne,
              t.quickStartTwo,
              t.quickStartThree,
              t.quickStartFour,
              t.quickStartFive,
              t.quickStartSix,
            ],
          ),
        ),
        GuidePanel(
          title: t.starterTargetTitle,
          body: t.starterTargetIntro,
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
          title: t.urDisciplineTitle,
          text: t.urDisciplineText,
        ),

        // ── Phase 2 — Your First Week ───────────────────────────────────
        GuidePhaseHeader(
          number: 2,
          title: t.phaseTwoTitle,
          subtitle: t.phaseTwoText,
        ),
        GuidePanel(
          title: t.starterCarryPlanTitle,
          body: t.starterCarryPlanText,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GuideSubheading(t.copySourcesTitle),
              const SizedBox(height: 10),
              BulletGuideList(
                items: [
                  t.copySourceStarter,
                  t.copySourceRace,
                  t.copySourceShards,
                  t.copySourceBattle,
                  t.copySourceCrates,
                  t.copySourceLightSpender,
                ],
              ),
            ],
          ),
        ),
        GuidePanel(
          title: t.gemSpendingTitle,
          body: t.gemSpendingIntro,
          child: BulletGuideList(
            items: [
              t.gemSpendingOne,
              t.gemSpendingTwo,
              t.gemSpendingThree,
              t.gemSpendingFour,
            ],
          ),
        ),
        GuideCallout(
          variant: GuideCalloutVariant.tip,
          title: t.gemTipTitle,
          text: t.gemTipText,
        ),
        GuidePanel(
          title: t.milestoneEventsTitle,
          body: t.milestoneEventsText,
        ),

        // ── Phase 3 — Your First Month & Beyond ─────────────────────────
        GuidePhaseHeader(
          number: 3,
          title: t.phaseThreeTitle,
          subtitle: t.phaseThreeText,
        ),
        HeroSpineSpotlight(
          spineId: '55007',
          eyebrow: t.jeanneSpotlightEyebrow,
          name: t.jeanneTitle,
          description: t.jeanneSpotlightText,
          ctaLabel: t.jeanneSpotlightCta,
          route: AppRoutes.heroPath('jeanne'),
        ),
        GuidePanel(
          title: t.day46EventsTitle,
          body: t.day46EventsText,
          child: BulletGuideList(
            items: [
              t.day46UrPlus,
              t.day46Beasts,
              t.day46Mirrors,
              t.day46UrPlusMirrors,
            ],
          ),
        ),
        GuidePanel(
          title: t.nextStepsTitle,
          child: FlexibleCardGrid(
            minTileWidth: 250,
            children: [
              GuideLinkCard(
                title: t.starterRerollTitle,
                text: t.starterRerollText,
                route: AppRoutes.reroll,
              ),
              GuideLinkCard(
                title: t.starterCarryTitle,
                text: t.starterCarryText,
                route: AppRoutes.starterCarry,
              ),
              GuideLinkCard(
                title: t.starterSpendTitle,
                text: t.starterSpendText,
                route: AppRoutes.shopPriority,
              ),
              GuideLinkCard(
                title: t.starterUrTitle,
                text: t.starterUrText,
                route: AppRoutes.urPriority,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
