import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:tc_flutter_web/features/guides/presentation/widgets/guide_kit.dart';
import 'package:tc_flutter_web/features/guides/presentation/widgets/hero_portrait_card.dart';

void main() {
  goldenTest(
    'new player guide widgets render across variants',
    fileName: 'getting_started_widgets',
    builder: () => GoldenTestGroup(
      columnWidthBuilder: (_) => const FixedColumnWidth(380),
      children: [
        GoldenTestScenario(
          name: 'phase header',
          child: Padding(
            padding: EdgeInsets.all(12),
            child: GuidePhaseHeader(
              number: 1,
              title: 'Your First Session',
              subtitle: 'Day one — get oriented and lock your direction.',
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'quick start stepper',
          child: Padding(
            padding: EdgeInsets.all(12),
            child: GuideStepper(
              steps: [
                'Start on the newest open server if you are rerolling.',
                'Use the free 1k summon at the beginning.',
                'Keep the account if it starts with Renais or Adele.',
              ],
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'callout — warning',
          child: Padding(
            padding: EdgeInsets.all(12),
            child: GuideCallout(
              variant: GuideCalloutVariant.warning,
              title: 'UR Scroll Discipline',
              text: 'Do not spend UR scrolls randomly across every banner.',
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'callout — tip',
          child: Padding(
            padding: EdgeInsets.all(12),
            child: GuideCallout(
              variant: GuideCalloutVariant.tip,
              title: 'When in Doubt, Save',
              text: 'Early gems usually do more on guaranteed progression.',
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'hero portrait card',
          child: Padding(
            padding: EdgeInsets.all(12),
            child: SizedBox(
              width: 240,
              child: HeroPortraitCard(
                name: 'Renais',
                role: 'Starter Carry',
                description: 'The preferred beginner carry target.',
                image: 'assets/img/heroes/renais/profile.png',
                route: '/docs/starter-carry',
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
