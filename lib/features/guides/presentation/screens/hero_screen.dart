import 'package:flutter/material.dart';

import 'package:tc_flutter_web/core/di/injection_container.dart';
import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import '../../domain/entities/hero_summary.dart';
import '../../domain/entities/soul_mirror.dart';
import '../../domain/repositories/hero_roster_repository.dart';
import '../../domain/repositories/soul_mirror_repository.dart';
import '../widgets/guide_kit.dart';
import '../widgets/soul_mirror_card.dart';
import '../widgets/soul_mirror_modal.dart';
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
            _MirrorHints(heroId: hero.id, heroName: hero.name),
          ],
        );
      },
    );
  }
}

/// Loads the Soul Mirror catalog and surfaces the mirror(s) bonded to this hero
/// as a recommendation. Renders nothing when the hero has no bonded mirror.
class _MirrorHints extends StatefulWidget {
  const _MirrorHints({required this.heroId, required this.heroName});

  final int heroId;
  final String heroName;

  @override
  State<_MirrorHints> createState() => _MirrorHintsState();
}

class _MirrorHintsState extends State<_MirrorHints> {
  Future<List<SoulMirror>>? _future;
  String? _languageCode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final code = Localizations.localeOf(context).languageCode;
    if (code != _languageCode) {
      _languageCode = code;
      _future = sl<SoulMirrorRepository>().loadAll(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return FutureBuilder<List<SoulMirror>>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final mirrors =
            snapshot.data!.where((m) => m.heroId == widget.heroId).toList();
        if (mirrors.isEmpty) return const SizedBox.shrink();
        return GuidePanel(
          title: t.heroMirrorHintsTitle,
          body: t.heroMirrorHintsBody(widget.heroName),
          child: Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              for (final m in mirrors)
                SoulMirrorCard(
                  mirror: m,
                  onTap: () => showSoulMirrorModal(context, m),
                ),
            ],
          ),
        );
      },
    );
  }
}
