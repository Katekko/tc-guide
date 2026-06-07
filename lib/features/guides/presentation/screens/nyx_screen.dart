import 'package:flutter/material.dart';

import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import '../widgets/guide_kit.dart';

/// The Nyx weapon page (draft).
class NyxScreen extends StatelessWidget {
  /// Creates the Nyx screen.
  const NyxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return GuideScaffold(
      title: t.nyxTitle,
      intro: t.statusDraft,
      children: [
        GuidePanel(
          title: t.toExtractTitle,
          child: BulletGuideList(
            items: [
              t.nyxExtractOne,
              t.nyxExtractTwo,
              t.nyxExtractThree,
            ],
          ),
        ),
      ],
    );
  }
}
