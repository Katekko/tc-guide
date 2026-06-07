import 'package:flutter/material.dart';

import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import '../widgets/guide_kit.dart';

/// The gear page (draft).
class GearsScreen extends StatelessWidget {
  /// Creates the gears screen.
  const GearsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return GuideScaffold(
      title: t.gearsTitle,
      intro: t.statusDraft,
      children: [
        GuidePanel(
          title: t.toExtractTitle,
          child: BulletGuideList(
            items: [
              t.gearsExtractOne,
              t.gearsExtractTwo,
              t.gearsExtractThree,
              t.gearsExtractFour,
            ],
          ),
        ),
      ],
    );
  }
}
