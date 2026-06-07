import 'package:flutter/material.dart';

import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import '../widgets/guide_kit.dart';

/// The tier list page (draft).
class TierListScreen extends StatelessWidget {
  /// Creates the tier list screen.
  const TierListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return GuideScaffold(
      title: t.tierListTitle,
      intro: t.statusDraft,
      children: [
        GuidePanel(
          title: t.toExtractTitle,
          child: BulletGuideList(
            items: [
              t.tierListExtractOne,
              t.tierListExtractTwo,
              t.tierListExtractThree,
              t.tierListExtractFour,
            ],
          ),
        ),
      ],
    );
  }
}
