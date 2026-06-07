import 'package:flutter/material.dart';

import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import '../widgets/guide_kit.dart';

/// The soul mirrors page (draft).
class SoulMirrorsScreen extends StatelessWidget {
  /// Creates the soul mirrors screen.
  const SoulMirrorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return GuideScaffold(
      title: t.soulMirrorsTitle,
      intro: t.statusDraft,
      children: [
        GuidePanel(
          title: t.toExtractTitle,
          child: BulletGuideList(
            items: [
              t.soulMirrorsExtractOne,
              t.soulMirrorsExtractTwo,
              t.soulMirrorsExtractThree,
              t.soulMirrorsExtractFour,
            ],
          ),
        ),
      ],
    );
  }
}
