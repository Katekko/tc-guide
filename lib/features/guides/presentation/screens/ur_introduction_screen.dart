import 'package:flutter/material.dart';

import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import '../widgets/guide_kit.dart';

/// The UR introduction page (draft).
class UrIntroductionScreen extends StatelessWidget {
  /// Creates the UR introduction screen.
  const UrIntroductionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return GuideScaffold(
      title: t.urIntroductionTitle,
      intro: t.statusDraft,
      children: [
        GuidePanel(
          title: t.toExtractTitle,
          child: BulletGuideList(
            items: [
              t.urIntroductionExtractOne,
              t.urIntroductionExtractTwo,
              t.urIntroductionExtractThree,
              t.urIntroductionExtractFour,
              t.urIntroductionExtractFive,
            ],
          ),
        ),
      ],
    );
  }
}
