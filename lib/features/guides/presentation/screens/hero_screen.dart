import 'package:flutter/material.dart';

import 'package:tc_flutter_web/core/di/injection_container.dart';
import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import '../../domain/entities/hero_summary.dart';
import '../../domain/repositories/hero_roster_repository.dart';
import '../widgets/guide_kit.dart';
import '../widgets/hero_mirror_tier_list.dart';
import 'hero_detail_screen.dart';

/// A single hero's page at `/heroes/:name`.
///
/// Resolves the route [slug] to a roster entry, then renders the game-faithful
/// [HeroDetailView] plus data-backed hints (the Soul Mirror bonded to the hero).
class HeroScreen extends StatefulWidget {
  /// Creates the hero page for the given route [slug] (e.g. `jeanne`).
  const HeroScreen({super.key, required this.slug});

  /// Shareable hero slug from the URL.
  final String slug;

  @override
  State<HeroScreen> createState() => _HeroScreenState();
}

class _HeroScreenState extends State<HeroScreen> {
  late Future<HeroSummary?> _hero = sl<HeroRosterRepository>().bySlug(widget.slug);

  @override
  void didUpdateWidget(HeroScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slug != widget.slug) {
      _hero = sl<HeroRosterRepository>().bySlug(widget.slug);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return FutureBuilder<HeroSummary?>(
      future: _hero,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          );
        }
        final hero = snapshot.data;
        if (hero == null) {
          return GuideScaffold(
            title: t.heroNotFoundTitle,
            intro: t.heroNotFoundBody,
            children: const [],
          );
        }
        return GuideScaffold(
          title: hero.name,
          children: [
            HeroDetailView(id: hero.id),
            const SizedBox(height: 8),
            HeroMirrorSection(heroId: hero.id, heroName: hero.name),
          ],
        );
      },
    );
  }
}
