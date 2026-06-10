import 'package:flutter/material.dart';

import 'package:tc_flutter_web/core/di/injection_container.dart';
import 'package:tc_flutter_web/core/theme/app_colors.dart';
import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import '../../domain/entities/hero_summary.dart';
import '../../domain/entities/team_comp.dart';
import '../../domain/repositories/hero_roster_repository.dart';
import '../../domain/repositories/team_comp_repository.dart';
import '../widgets/guide_kit.dart';
import '../widgets/team_comp_card.dart';

/// The team comps page: a "team building 101" primer followed by one card per
/// curated comp (engine core), rendered from per-locale comp data.
class TeamCompsScreen extends StatelessWidget {
  /// Creates the team comps screen.
  const TeamCompsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return GuideScaffold(
      title: t.teamCompsTitle,
      intro: t.teamCompsIntro,
      children: [
        GuidePanel(
          title: t.teamCompsBasicsTitle,
          child: BulletGuideList(
            items: [
              t.teamCompsBasicsSlots,
              t.teamCompsBasicsLines,
              t.teamCompsBasicsEngine,
              t.teamCompsBasicsRace,
              t.teamCompsBasicsOtherworld,
            ],
          ),
        ),
        const _TeamCompsList(),
      ],
    );
  }
}

/// Loads the comps + roster index and renders one [TeamCompCard] per comp.
class _TeamCompsList extends StatefulWidget {
  const _TeamCompsList();

  @override
  State<_TeamCompsList> createState() => _TeamCompsListState();
}

class _TeamCompsListState extends State<_TeamCompsList> {
  Future<(List<TeamComp>, Map<int, HeroSummary>)>? _future;
  String? _languageCode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final code = Localizations.localeOf(context).languageCode;
    if (code != _languageCode) {
      _languageCode = code;
      _future = _load(code);
    }
  }

  Future<(List<TeamComp>, Map<int, HeroSummary>)> _load(String code) async {
    final comps = await sl<TeamCompRepository>().loadAll(code);
    final roster = await sl<HeroRosterRepository>().loadAll();
    return (comps, {for (final hero in roster) hero.id: hero});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<(List<TeamComp>, Map<int, HeroSummary>)>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Failed to load team comps: ${snapshot.error}',
              style: const TextStyle(color: AppColors.secondaryText),
            ),
          );
        }
        final data = snapshot.data;
        if (data == null) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final (comps, heroById) = data;
        return Column(
          children: [
            for (final comp in comps)
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: TeamCompCard(comp: comp, heroById: heroById),
              ),
          ],
        );
      },
    );
  }
}
