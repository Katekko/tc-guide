import 'package:flutter/material.dart';

import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import '../widgets/guide_kit.dart';
import '../widgets/star_up_cost_view.dart';

/// The Heroes → Star-Up page: the universal SSR+ → Opal 5★ grade cost
/// reference. A sidebar nav item under "Heroes" (`/heroes/star-up`).
class HeroesStarUpScreen extends StatelessWidget {
  /// Creates the star-up costs screen.
  const HeroesStarUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return GuideScaffold(
      title: t.heroesStarUpTitle,
      intro: t.heroesStarUpIntro,
      children: const [StarUpCostView()],
    );
  }
}
