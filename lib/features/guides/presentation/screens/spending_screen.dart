import 'package:flutter/material.dart';

import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import '../widgets/guide_kit.dart';

/// The spending guide page (draft).
class SpendingScreen extends StatelessWidget {
  /// Creates the spending screen.
  const SpendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return GuideScaffold(
      title: t.spendingTitle,
      intro: t.statusDraft,
      children: [
        GuidePanel(
          title: t.toExtractTitle,
          child: BulletGuideList(
            items: [
              t.spendingExtractOne,
              t.spendingExtractTwo,
              t.spendingExtractThree,
              t.spendingExtractFour,
            ],
          ),
        ),
      ],
    );
  }
}
