import 'package:flutter/material.dart';

import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import '../widgets/guide_scaffold.dart';
import 'hero_detail_screen.dart';

/// The Jeanne hero page — renders the game-faithful hero detail view.
class JeanneScreen extends StatelessWidget {
  /// Creates the Jeanne screen.
  const JeanneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return GuideScaffold(
      title: t.jeanneTitle,
      children: const [
        HeroDetailView(id: 55007),
      ],
    );
  }
}
