import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tc_flutter_web/core/router/app_routes.dart';
import 'package:tc_flutter_web/core/theme/app_colors.dart';
import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import '../../domain/entities/hero_summary.dart';
import '../../domain/entities/team_comp.dart';
import 'guide_text.dart';

/// A team composition card: tier badge + engine chip header, a Budget/Endgame
/// variant toggle, the lineup laid out as the in-game battle grid
/// (front / mid / back columns), the live race-bonus strip, and the
/// "why it works" explanation.
///
/// Tapping a hero opens a popover with their role in the comp and a link to
/// their hero page (kit + mirror ranking).
class TeamCompCard extends StatefulWidget {
  /// Creates a card for [comp].
  const TeamCompCard({required this.comp, required this.heroById, super.key});

  /// The comp to render.
  final TeamComp comp;

  /// Roster lookup used to resolve slot hero ids to display data.
  final Map<int, HeroSummary> heroById;

  @override
  State<TeamCompCard> createState() => _TeamCompCardState();
}

class _TeamCompCardState extends State<TeamCompCard> {
  int _variant = 0;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final comp = widget.comp;
    final variant = comp.variants[_variant];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(comp: comp),
            const SizedBox(height: 6),
            GuideParagraph(comp.summary),
            const SizedBox(height: 14),
            if (comp.variants.length > 1) ...[
              _VariantToggle(
                variants: comp.variants,
                selected: _variant,
                onChanged: (i) => setState(() => _variant = i),
              ),
              const SizedBox(height: 14),
            ],
            _BattleGrid(variant: variant, heroById: widget.heroById),
            const SizedBox(height: 14),
            _RaceBonusStrip(variant: variant, heroById: widget.heroById),
            const SizedBox(height: 14),
            Text(
              t.teamCompsWhyItWorks,
              style: const TextStyle(
                color: AppColors.primaryText,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            GuideParagraph(comp.whyItWorks),
            if (comp.mirrorNote.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.auto_awesome,
                      size: 16, color: AppColors.link),
                  const SizedBox(width: 6),
                  Expanded(child: GuideParagraph(comp.mirrorNote)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.comp});

  final TeamComp comp;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _TierBadge(tier: comp.tier),
        Text(
          comp.name,
          style: const TextStyle(
            color: AppColors.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        _EngineChip(engine: comp.engine),
      ],
    );
  }
}

class _TierBadge extends StatelessWidget {
  const _TierBadge({required this.tier});

  final String tier;

  @override
  Widget build(BuildContext context) {
    const color = Color(0xffd9a441);
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        tier,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 15,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _EngineChip extends StatelessWidget {
  const _EngineChip({required this.engine});

  final String engine;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x264568f0),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x594568f0)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          '[$engine]',
          style: const TextStyle(
            color: AppColors.link,
            fontSize: 12,
            height: 1,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _VariantToggle extends StatelessWidget {
  const _VariantToggle({
    required this.variants,
    required this.selected,
    required this.onChanged,
  });

  final List<TeamCompVariant> variants;
  final int selected;
  final ValueChanged<int> onChanged;

  String _label(AppLocalizations t, String key) => switch (key) {
        'endgame' => t.teamCompsVariantEndgame,
        'budget' => t.teamCompsVariantBudget,
        _ => key,
      };

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Wrap(
      spacing: 8,
      children: [
        for (var i = 0; i < variants.length; i++)
          ChoiceChip(
            label: Text(_label(t, variants[i].key)),
            selected: i == selected,
            onSelected: (_) => onChanged(i),
            labelStyle: TextStyle(
              color: i == selected ? AppColors.link : AppColors.secondaryText,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            selectedColor: const Color(0x264568f0),
            backgroundColor: AppColors.selectedBackground,
            side: BorderSide(
              color: i == selected
                  ? const Color(0x594568f0)
                  : AppColors.cardBorder,
            ),
            showCheckmark: false,
          ),
      ],
    );
  }
}

/// The lineup laid out like the in-game deploy grid: three labeled columns
/// (front / mid / back) holding the slot tiles.
class _BattleGrid extends StatelessWidget {
  const _BattleGrid({required this.variant, required this.heroById});

  final TeamCompVariant variant;
  final Map<int, HeroSummary> heroById;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    // Mirrors the in-game deploy view: your team faces the enemy on the
    // right, so the frontline is the rightmost column.
    final lines = <(String, String)>[
      ('back', t.teamCompsLineBack),
      ('mid', t.teamCompsLineMid),
      ('front', t.teamCompsLineFront),
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (key, label) in lines)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final slot in variant.slots.where((s) => s.line == key))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _SlotTile(slot: slot, hero: heroById[slot.heroId]),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _SlotTile extends StatelessWidget {
  const _SlotTile({required this.slot, required this.hero});

  final TeamCompSlot slot;
  final HeroSummary? hero;

  @override
  Widget build(BuildContext context) {
    final hero = this.hero;
    final name = hero?.name ?? '#${slot.heroId}';
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 132),
      child: Material(
        color: AppColors.selectedBackground,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _showWhy(context),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: hero == null
                        ? const ColoredBox(color: Colors.black45)
                        : Image.asset(
                            hero.portrait,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Center(
                              child: Text(
                                name.characters.first,
                                style: const TextStyle(
                                  color: AppColors.link,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  slot.role,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showWhy(BuildContext context) {
    final t = AppLocalizations.of(context);
    final hero = this.hero;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        title: Text(
          hero?.name ?? '#${slot.heroId}',
          style: const TextStyle(
            color: AppColors.primaryText,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                slot.role,
                style: const TextStyle(
                  color: AppColors.link,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              GuideParagraph(slot.why),
            ],
          ),
        ),
        actions: [
          if (hero != null)
            TextButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.go(AppRoutes.heroPath(hero.slug));
              },
              icon: const Icon(Icons.open_in_new, size: 16),
              label: Text(t.teamCompsViewBuild),
            ),
        ],
      ),
    );
  }
}

/// The same-faction deploy bonus the lineup reaches, computed live from the
/// heroes' factions (Otherworld counts as any faction; an all-Otherworld team
/// gets the dedicated tier with Final DMG).
class _RaceBonusStrip extends StatelessWidget {
  const _RaceBonusStrip({required this.variant, required this.heroById});

  final TeamCompVariant variant;
  final Map<int, HeroSummary> heroById;

  /// Same-race tiers from the in-game tooltip: count -> (ATK, DEF, HP) %.
  static const _tiers = {
    2: (8, 5, 10),
    3: (10, 7, 15),
    4: (13, 9, 20),
    5: (16, 11, 25),
    6: (18, 13, 30),
  };

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final factions = variant.slots
        .map((s) => heroById[s.heroId]?.faction)
        .whereType<String>()
        .toList();
    final otherworld = factions.where((f) => f == 'Otherworld').length;

    String? text;
    if (factions.length == 6 && otherworld == 6) {
      text = t.teamCompsRaceBonusOtherworld;
    } else {
      var bestFaction = '';
      var bestCount = 0;
      for (final f in factions.toSet().where((f) => f != 'Otherworld')) {
        final count = factions.where((x) => x == f).length + otherworld;
        if (count > bestCount) {
          bestFaction = f;
          bestCount = count;
        }
      }
      final tier = _tiers[bestCount.clamp(0, 6)];
      if (tier != null) {
        text = t.teamCompsRaceBonus(
            bestCount, bestFaction, tier.$1, tier.$2, tier.$3);
      }
    }
    if (text == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0x1ad9a441),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x59d9a441)),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt, size: 16, color: Color(0xffd9a441)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.primaryText,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
