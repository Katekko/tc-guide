import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tc_flutter_web/core/di/injection_container.dart';
import 'package:tc_flutter_web/core/router/app_routes.dart';
import 'package:tc_flutter_web/core/theme/app_colors.dart';
import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import '../../domain/entities/hero_summary.dart';
import '../../domain/repositories/hero_roster_repository.dart';
import '../widgets/guide_kit.dart';
import '../widgets/hero_roster_card.dart';

/// The Heroes catalog: a searchable, filterable grid of every hero. Tapping a
/// hero opens its page (`/heroes/:name`).
class HeroesScreen extends StatelessWidget {
  /// Creates the heroes catalog screen.
  const HeroesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return GuideScaffold(
      title: t.heroesTitle,
      intro: t.heroesIntro,
      children: const [_HeroBrowser()],
    );
  }
}

/// Loads the roster and drives the search box + class/rarity filters.
class _HeroBrowser extends StatefulWidget {
  const _HeroBrowser();

  @override
  State<_HeroBrowser> createState() => _HeroBrowserState();
}

class _HeroBrowserState extends State<_HeroBrowser> {
  final Future<List<HeroSummary>> _future = sl<HeroRosterRepository>().loadAll();

  String _query = '';
  String? _heroClass;
  String? _rarity;
  String? _faction;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<HeroSummary>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Failed to load heroes: ${snapshot.error}',
              style: const TextStyle(color: AppColors.secondaryText),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return _Browser(
          all: snapshot.data!,
          query: _query,
          heroClass: _heroClass,
          rarity: _rarity,
          faction: _faction,
          onQuery: (v) => setState(() => _query = v),
          onClass: (v) => setState(() => _heroClass = v),
          onRarity: (v) => setState(() => _rarity = v),
          onFaction: (v) => setState(() => _faction = v),
        );
      },
    );
  }
}

class _Browser extends StatelessWidget {
  const _Browser({
    required this.all,
    required this.query,
    required this.heroClass,
    required this.rarity,
    required this.faction,
    required this.onQuery,
    required this.onClass,
    required this.onRarity,
    required this.onFaction,
  });

  final List<HeroSummary> all;
  final String query;
  final String? heroClass;
  final String? rarity;
  final String? faction;
  final ValueChanged<String> onQuery;
  final ValueChanged<String?> onClass;
  final ValueChanged<String?> onRarity;
  final ValueChanged<String?> onFaction;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    // Filter options derived from the actual roster, in stable order.
    final classes = {for (final h in all) h.heroClass}.toList()..sort();
    final rarities = {for (final h in all) h.rarity}.toList()..sort();
    final factions = {for (final h in all) h.faction}.toList()..sort();

    final q = query.trim().toLowerCase();
    final filtered = all.where((h) {
      if (q.isNotEmpty && !h.name.toLowerCase().contains(q)) return false;
      if (heroClass != null && h.heroClass != heroClass) return false;
      if (rarity != null && h.rarity != rarity) return false;
      if (faction != null && h.faction != faction) return false;
      return true;
    }).toList()
      // Strongest rarity first (UR+ → UR → SSR+ → SSR → R → N), then by name.
      ..sort((a, b) {
        final byRarity = _rarityRank(b.rarity).compareTo(_rarityRank(a.rarity));
        return byRarity != 0
            ? byRarity
            : a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          onChanged: onQuery,
          style: const TextStyle(color: AppColors.primaryText, fontSize: 14),
          decoration: InputDecoration(
            isDense: true,
            hintText: l.heroSearchHint,
            hintStyle: const TextStyle(color: AppColors.mutedText),
            prefixIcon: const Icon(Icons.search, color: AppColors.mutedText),
            filled: true,
            fillColor: AppColors.cardBackground,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.cardHoverBorder),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _Chip(
              label: l.heroFilterAll,
              selected: heroClass == null,
              color: AppColors.link,
              onTap: () => onClass(null),
            ),
            for (final c in classes)
              _Chip(
                label: c,
                selected: heroClass == c,
                color: AppColors.secondaryText,
                onTap: () => onClass(c),
              ),
          ],
        ),
        if (rarities.length > 1) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final r in rarities)
                _Chip(
                  label: r,
                  selected: rarity == r,
                  color: const Color(0xffd9a441),
                  onTap: () => onRarity(rarity == r ? null : r),
                ),
            ],
          ),
        ],
        if (factions.length > 1) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final f in factions)
                _Chip(
                  label: f,
                  selected: faction == f,
                  color: const Color(0xff9b8cff),
                  onTap: () => onFaction(faction == f ? null : f),
                ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        Text(
          '${filtered.length} ${l.heroShownLabel}',
          style: const TextStyle(
            color: AppColors.mutedText,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 36),
            child: Center(
              child: Text(
                l.heroEmpty,
                style: const TextStyle(color: AppColors.secondaryText),
              ),
            ),
          )
        else
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              for (final h in filtered)
                HeroRosterCard(
                  hero: h,
                  onTap: () => context.go(AppRoutes.heroPath(h.slug)),
                ),
            ],
          ),
      ],
    );
  }
}

/// Sort weight for a rarity tier (higher = stronger / shown first).
int _rarityRank(String rarity) => const {
      'UR+': 6,
      'UR': 5,
      'SSR+': 4,
      'SSR': 3,
      'R': 2,
      'N': 1,
    }[rarity] ??
    0;

/// A small toggleable filter chip matching the dark theme.
class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? color.withValues(alpha: 0.18) : AppColors.cardBackground,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? color : AppColors.cardBorder),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? color : AppColors.secondaryText,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
