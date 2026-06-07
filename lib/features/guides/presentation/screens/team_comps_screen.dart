import 'package:flutter/material.dart';

import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import '../widgets/guide_kit.dart';

/// The team comps page (draft).
class TeamCompsScreen extends StatelessWidget {
  /// Creates the team comps screen.
  const TeamCompsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return GuideScaffold(
      title: t.teamCompsTitle,
      intro: t.statusDraft,
      children: [
        GuidePanel(
          title: t.toExtractTitle,
          child: BulletGuideList(
            items: [
              t.teamCompsExtractOne,
              t.teamCompsExtractTwo,
              t.teamCompsExtractThree,
              t.teamCompsExtractFour,
            ],
          ),
        ),
      ],
    );
  }
}
