import 'package:flutter/material.dart';

import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import '../widgets/guide_kit.dart';

/// The stats page (draft).
class StatsScreen extends StatelessWidget {
  /// Creates the stats screen.
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return GuideScaffold(
      title: t.statsTitle,
      intro: t.statusDraft,
      children: [
        GuidePanel(
          title: t.toExtractTitle,
          child: BulletGuideList(
            items: [
              t.statsExtractOne,
              t.statsExtractTwo,
              t.statsExtractThree,
              t.statsExtractFour,
            ],
          ),
        ),
      ],
    );
  }
}
