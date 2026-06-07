import 'package:flutter/material.dart';

import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import '../widgets/guide_kit.dart';

/// The starter carry route page: the copy-acquisition route as a stepper, UR
/// scroll discipline and light-spender caveats as callouts, and the remaining
/// editorial follow-ups noted at the end.
class StarterCarryScreen extends StatelessWidget {
  /// Creates the starter carry screen.
  const StarterCarryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return GuideScaffold(
      title: t.starterCarryPageTitle,
      intro: t.starterCarryScopeText,
      children: [
        GuidePanel(
          title: t.starterCarryMainIdeaTitle,
          body: t.starterCarryMainIdeaText,
          child: GuideStepper(
            steps: [
              t.starterCarryIdeaOne,
              t.starterCarryIdeaTwo,
              t.starterCarryIdeaThree,
              t.starterCarryIdeaFour,
              t.starterCarryIdeaFive,
            ],
          ),
        ),
        GuideCallout(
          variant: GuideCalloutVariant.warning,
          title: t.starterCarryScrollTitle,
          text: t.starterCarryScrollText,
        ),
        GuideCallout(
          variant: GuideCalloutVariant.info,
          title: t.starterCarryLightTitle,
          text: t.starterCarryLightText,
        ),
        GuideCallout(
          title: t.starterCarryCleanupTitle,
          child: BulletGuideList(
            items: [
              t.starterCarryCleanupOne,
              t.starterCarryCleanupTwo,
              t.starterCarryCleanupThree,
              t.starterCarryCleanupFour,
            ],
          ),
        ),
      ],
    );
  }
}
