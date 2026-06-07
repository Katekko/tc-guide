import 'package:flutter/material.dart';

import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import '../widgets/guide_kit.dart';

/// The UR priority page (draft).
class UrPriorityScreen extends StatelessWidget {
  /// Creates the UR priority screen.
  const UrPriorityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return GuideScaffold(
      title: t.urPriorityTitle,
      intro: t.statusDraft,
      children: [
        GuidePanel(
          title: t.toExtractTitle,
          child: BulletGuideList(
            items: [
              t.urPriorityExtractOne,
              t.urPriorityExtractTwo,
              t.urPriorityExtractThree,
              t.urPriorityExtractFour,
            ],
          ),
        ),
      ],
    );
  }
}
