import 'package:flutter/material.dart';

import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import '../widgets/guide_kit.dart';

/// The UR+ page (draft).
class UrPlusScreen extends StatelessWidget {
  /// Creates the UR+ screen.
  const UrPlusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return GuideScaffold(
      title: t.urPlusTitle,
      intro: t.statusDraft,
      children: [
        GuidePanel(
          title: t.toExtractTitle,
          child: BulletGuideList(
            items: [
              t.urPlusExtractOne,
              t.urPlusExtractTwo,
              t.urPlusExtractThree,
              t.urPlusExtractFour,
            ],
          ),
        ),
      ],
    );
  }
}
