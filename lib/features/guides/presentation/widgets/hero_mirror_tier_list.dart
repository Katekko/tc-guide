import 'package:flutter/material.dart';

import 'package:tc_flutter_web/core/di/injection_container.dart';
import 'package:tc_flutter_web/core/theme/app_colors.dart';
import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import '../../domain/entities/hero_mirror_ranking.dart';
import '../../domain/entities/soul_mirror.dart';
import '../../domain/repositories/hero_mirror_repository.dart';
import '../../domain/repositories/soul_mirror_repository.dart';
import 'guide_panel.dart';
import 'soul_mirror_card.dart';
import 'soul_mirror_kit.dart';
import 'soul_mirror_modal.dart';

/// The hero page's mirror section. When the hero has a curated ranking
/// (`assets/data/heroes/<id>.mirrors.json`) it renders a full S→F tier list;
/// otherwise it falls back to the hero's bonded-mirror hint.
class HeroMirrorSection extends StatefulWidget {
  /// Creates the section for the given hero.
  const HeroMirrorSection(
      {required this.heroId, required this.heroName, super.key});

  /// Hero id, used to load the ranking and match the bonded mirror.
  final int heroId;

  /// Hero display name (used in the fallback hint copy).
  final String heroName;

  @override
  State<HeroMirrorSection> createState() => _HeroMirrorSectionState();
}

class _HeroMirrorSectionState extends State<HeroMirrorSection> {
  Future<_MirrorData>? _future;
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

  Future<_MirrorData> _load(String code) async {
    final catalog = await sl<SoulMirrorRepository>().loadAll(code);
    final ranking = await sl<HeroMirrorRepository>().load(widget.heroId);
    return _MirrorData(
      byId: {for (final m in catalog) m.id: m},
      ranking: ranking,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return FutureBuilder<_MirrorData>(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) return const SizedBox.shrink();

        final ranking = data.ranking;
        if (ranking != null && ranking.picks.isNotEmpty) {
          return GuidePanel(
            title: t.heroMirrorRankingTitle,
            body: ranking.profile.isEmpty ? null : ranking.profile,
            child: _TierList(ranking: ranking, byId: data.byId),
          );
        }
        return _fallbackHint(context, t, data.byId);
      },
    );
  }

  /// Uncurated heroes still get their bonded mirror (the old behavior).
  Widget _fallbackHint(
      BuildContext context, AppLocalizations t, Map<int, SoulMirror> byId) {
    final bonded = byId.values.where((m) => m.heroId == widget.heroId).toList();
    if (bonded.isEmpty) return const SizedBox.shrink();
    return GuidePanel(
      title: t.heroMirrorHintsTitle,
      body: t.heroMirrorHintsBody(widget.heroName),
      child: Wrap(
        spacing: 14,
        runSpacing: 14,
        children: [
          for (final m in bonded)
            SoulMirrorCard(mirror: m, onTap: () => showSoulMirrorModal(context, m)),
        ],
      ),
    );
  }
}

class _MirrorData {
  const _MirrorData({required this.byId, required this.ranking});

  final Map<int, SoulMirror> byId;
  final HeroMirrorRanking? ranking;
}

/// The S/A/B/C/D/F tier rows. Top tiers (S/A/B) are always shown; the weaker
/// tiers (C/D/F) collapse behind a single toggle to keep the page short.
class _TierList extends StatefulWidget {
  const _TierList({required this.ranking, required this.byId});

  final HeroMirrorRanking ranking;
  final Map<int, SoulMirror> byId;

  @override
  State<_TierList> createState() => _TierListState();
}

class _TierListState extends State<_TierList> {
  static const _alwaysShown = {MirrorTier.s, MirrorTier.a, MirrorTier.b};
  static const _order = [
    MirrorTier.s,
    MirrorTier.a,
    MirrorTier.b,
    MirrorTier.c,
    MirrorTier.d,
    MirrorTier.f,
  ];

  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final byTier = <MirrorTier, List<HeroMirrorPick>>{};
    for (final p in widget.ranking.picks) {
      byTier.putIfAbsent(p.tier, () => []).add(p);
    }

    final collapsedTiers = _order
        .where((tier) => !_alwaysShown.contains(tier))
        .where((tier) => (byTier[tier] ?? const []).isNotEmpty)
        .toList();
    final collapsedCount = collapsedTiers.fold<int>(
        0, (sum, tier) => sum + (byTier[tier]?.length ?? 0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final tier in _order)
          if ((byTier[tier] ?? const []).isNotEmpty &&
              (_alwaysShown.contains(tier) || _showAll))
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _TierRow(tier: tier, picks: byTier[tier]!, byId: widget.byId),
            ),
        if (collapsedTiers.isNotEmpty)
          _ToggleButton(
            expanded: _showAll,
            collapsedCount: collapsedCount,
            onTap: () => setState(() => _showAll = !_showAll),
          ),
      ],
    );
  }
}

class _TierRow extends StatelessWidget {
  const _TierRow({required this.tier, required this.picks, required this.byId});

  final MirrorTier tier;
  final List<HeroMirrorPick> picks;
  final Map<int, SoulMirror> byId;

  @override
  Widget build(BuildContext context) {
    final color = _tierColor(tier);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TierBadge(tier: tier, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final p in picks)
                _MirrorChip(pick: p, mirror: byId[p.mirrorId], accent: color),
            ],
          ),
        ),
      ],
    );
  }
}

class _TierBadge extends StatelessWidget {
  const _TierBadge({required this.tier, required this.color});

  final MirrorTier tier;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.7)),
      ),
      child: Text(
        tier.label,
        style: TextStyle(
          color: color,
          fontSize: 17,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

/// A compact, tappable mirror tile inside a tier row: portrait + quality border,
/// an optional "N★" breakpoint badge, and the mirror name. Tap opens the detail
/// modal with the per-hero rationale.
class _MirrorChip extends StatelessWidget {
  const _MirrorChip(
      {required this.pick, required this.mirror, required this.accent});

  final HeroMirrorPick pick;
  final SoulMirror? mirror;
  final Color accent;

  static const double _size = 58;

  @override
  Widget build(BuildContext context) {
    final m = mirror;
    final type =
        SoulMirrorTypeStyle.of(m?.type ?? SoulMirrorType.unknown);
    final quality =
        SoulMirrorQualityStyle.of(m?.quality ?? SoulMirrorQuality.unknown);
    final star = pick.recommendedStar;
    final showStar = star != null && star > 0;

    return SizedBox(
      width: _size,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: m == null
                  ? null
                  : () => showSoulMirrorModal(context, m,
                      reason: pick.reason, recommendedStar: pick.recommendedStar),
              child: SizedBox(
                width: _size,
                height: _size,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: quality.color.withValues(alpha: 0.7),
                                width: 1.5),
                          ),
                          child: Image.asset(
                            'assets/img/soul_mirrors/${pick.mirrorId}.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _ChipPlaceholder(
                                color: type.color, name: pick.name),
                          ),
                        ),
                      ),
                    ),
                    if (showStar)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.78),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                                color: accent.withValues(alpha: 0.9)),
                          ),
                          child: Text(
                            '$star★',
                            style: TextStyle(
                              color: accent,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            pick.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipPlaceholder extends StatelessWidget {
  const _ChipPlaceholder({required this.color, required this.name});

  final Color color;
  final String name;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.32), Colors.black54],
        ),
      ),
      child: Center(
        child: Text(
          name.isEmpty ? '?' : name.characters.first.toUpperCase(),
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.expanded,
    required this.collapsedCount,
    required this.onTap,
  });

  final bool expanded;
  final int collapsedCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(expanded ? Icons.expand_less : Icons.expand_more, size: 18),
      label: Text(expanded
          ? t.heroMirrorShowLess
          : t.heroMirrorShowMore(collapsedCount)),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.secondaryText,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }
}

Color _tierColor(MirrorTier tier) {
  switch (tier) {
    case MirrorTier.s:
      return const Color(0xffe0b24c); // gold
    case MirrorTier.a:
      return const Color(0xff4fd6a0); // green
    case MirrorTier.b:
      return const Color(0xff5fa8ff); // blue
    case MirrorTier.c:
      return const Color(0xff9aa6bd); // grey
    case MirrorTier.d:
      return const Color(0xff8190aa); // muted
    case MirrorTier.f:
    case MirrorTier.unknown:
      return const Color(0xffe5677a); // red
  }
}
