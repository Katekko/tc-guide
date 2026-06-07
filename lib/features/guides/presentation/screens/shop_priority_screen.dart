import 'package:flutter/material.dart';

import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import '../widgets/guide_kit.dart';

/// The shop priority page (draft).
class ShopPriorityScreen extends StatelessWidget {
  /// Creates the shop priority screen.
  const ShopPriorityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return GuideScaffold(
      title: t.shopPriorityTitle,
      intro: t.statusDraft,
      children: [
        GuidePanel(
          title: t.toExtractTitle,
          child: BulletGuideList(
            items: [
              t.shopPriorityExtractOne,
              t.shopPriorityExtractTwo,
              t.shopPriorityExtractThree,
              t.shopPriorityExtractFour,
            ],
          ),
        ),
      ],
    );
  }
}
