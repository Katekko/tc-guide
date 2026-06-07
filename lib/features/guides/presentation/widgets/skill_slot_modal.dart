import 'package:flutter/material.dart';

import 'package:tc_flutter_web/core/theme/app_colors.dart';
import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import '../../domain/entities/hero_detail.dart';
import 'game_rich_text.dart';

/// The slot's accent color, echoing the in-game tab tints. Keyed off the
/// locale-independent slot key ("skills"/"ultimate"/"awaken"/"genesis").
Color slotColor(String key) {
  switch (key) {
    case 'ultimate':
      return const Color(0xff5fa8ff);
    case 'awaken':
      return const Color(0xffd9a441);
    case 'genesis':
      return const Color(0xff4fd6a0);
    case 'skills':
    default:
      return const Color(0xffe8c66a);
  }
}

/// Per-tier accent colors for the Genesis ladder (green→blue→purple→gold→red),
/// matching the in-game Genesis Skill panel.
const List<Color> genesisTierColors = [
  Color(0xff4fd6a0),
  Color(0xff5fa8ff),
  Color(0xffa06fff),
  Color(0xffd9a441),
  Color(0xffe5677a),
];

/// Shows the skill detail modal for [slotData], mirroring the in-game popup.
///
/// Genesis is a distinct dupe-fed mechanic (not tied to evolution grade), so it
/// gets its own locked-ladder modal; every other slot uses the standard popup.
/// [unlockedTiers] (for the grade-driven Awaken passive) locks tiers above it.
Future<void> showSkillSlotModal(
  BuildContext context,
  HeroSkillSlot slotData, {
  int? unlockedTiers,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black87,
    builder: (_) => slotData.key == 'genesis'
        ? _GenesisModal(slot: slotData)
        : _SkillSlotModal(slot: slotData, unlockedTiers: unlockedTiers),
  );
}

class _SkillSlotModal extends StatelessWidget {
  const _SkillSlotModal({required this.slot, this.unlockedTiers});

  final HeroSkillSlot slot;

  /// When set, passive tiers above this count render locked (grade-driven).
  final int? unlockedTiers;

  @override
  Widget build(BuildContext context) {
    final accent = slotColor(slot.key);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: const Color(0xf21a2336),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent.withValues(alpha: 0.55)),
          boxShadow: const [
            BoxShadow(color: Colors.black54, blurRadius: 24, spreadRadius: 2),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(slot: slot, accent: accent),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: slot.isPassive
                    ? _Effects(
                        slot: slot, accent: accent, unlockedTiers: unlockedTiers)
                    : _ActiveBody(slot: slot, accent: accent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.slot, required this.accent});

  final HeroSkillSlot slot;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SkillIcon(slotKey: slot.key, accent: accent, size: 48),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                slot.name,
                style: const TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                slot.type,
                style: TextStyle(
                  color: accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActiveBody extends StatelessWidget {
  const _ActiveBody({required this.slot, required this.accent});

  final HeroSkillSlot slot;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GameRichText(
          slot.description ?? '',
          baseStyle: const TextStyle(
            color: AppColors.bodyText,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        if (slot.releaseTurn != null || slot.cooldown != null) ...[
          const SizedBox(height: 14),
          DefaultTextStyle(
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            child: Wrap(
              spacing: 16,
              children: [
                if (slot.releaseTurn != null)
                  _ChipFact(l.skillReleaseLabel, slot.releaseTurn!, accent),
                if (slot.cooldown != null)
                  _ChipFact(l.skillCooldownLabel, slot.cooldown!, accent,
                      suffix: l.turnsLabel),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ChipFact extends StatelessWidget {
  const _ChipFact(this.label, this.value, this.accent, {this.suffix});

  final String label;
  final int value;
  final Color accent;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Text.rich(TextSpan(children: [
      TextSpan(text: '$label '),
      TextSpan(
        text: '$value',
        style: TextStyle(color: accent, fontWeight: FontWeight.w800),
      ),
      if (suffix != null) TextSpan(text: ' $suffix'),
    ]));
  }
}

class _Effects extends StatelessWidget {
  const _Effects({required this.slot, required this.accent, this.unlockedTiers});

  final HeroSkillSlot slot;
  final Color accent;

  /// When set, tiers above this count render locked (grade-driven Awaken).
  final int? unlockedTiers;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final e in slot.effects)
          Builder(builder: (context) {
            final locked = unlockedTiers != null && e.tier > unlockedTiers!;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Opacity(
                opacity: locked ? 0.55 : 1,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: locked ? 0.06 : 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: accent.withValues(alpha: locked ? 0.3 : 0.6)),
                      ),
                      child: locked
                          ? Icon(Icons.lock,
                              color: AppColors.mutedText, size: 13)
                          : Text(
                              '${e.tier}',
                              style: TextStyle(
                                color: accent,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GameRichText(
                        e.description,
                        baseStyle: const TextStyle(
                          color: AppColors.bodyText,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}

/// The Genesis modal: a 5-tier locked ladder fed by hero dupes (not evolution
/// grade). Tiers above the chosen Genesis level show a padlock, but every
/// description stays readable — matching the in-game Genesis Skill panel.
class _GenesisModal extends StatefulWidget {
  const _GenesisModal({required this.slot});

  final HeroSkillSlot slot;

  @override
  State<_GenesisModal> createState() => _GenesisModalState();
}

class _GenesisModalState extends State<_GenesisModal> {
  late int _level = widget.slot.effects.length; // default: all unlocked

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final effects = widget.slot.effects;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        decoration: BoxDecoration(
          color: const Color(0xf21a2336),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xff4fd6a0).withValues(alpha: 0.5)),
          boxShadow: const [
            BoxShadow(color: Colors.black54, blurRadius: 24, spreadRadius: 2),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                l.genesisSkillTitle,
                style: const TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _GenesisLevelPicker(
              count: effects.length,
              level: _level,
              onChanged: (v) => setState(() => _level = v),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (var i = 0; i < effects.length; i++)
                      _GenesisRow(
                        effect: effects[i],
                        color: genesisTierColors[i % genesisTierColors.length],
                        locked: (i + 1) > _level,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l.genesisFooter,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.mutedText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Segmented 1..N picker for how many Genesis tiers are unlocked.
class _GenesisLevelPicker extends StatelessWidget {
  const _GenesisLevelPicker({
    required this.count,
    required this.level,
    required this.onChanged,
  });

  final int count;
  final int level;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final label = AppLocalizations.of(context).genesisLevelLabel;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 1; i <= count; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: InkWell(
              onTap: () => onChanged(i),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i <= level
                      ? genesisTierColors[(i - 1) % genesisTierColors.length]
                          .withValues(alpha: 0.25)
                      : Colors.transparent,
                  border: Border.all(
                    color: i <= level
                        ? genesisTierColors[(i - 1) % genesisTierColors.length]
                        : AppColors.cardBorder,
                  ),
                ),
                child: Text(
                  '$i',
                  style: TextStyle(
                    color: i <= level
                        ? genesisTierColors[(i - 1) % genesisTierColors.length]
                        : AppColors.mutedText,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(width: 8),
        Text(
          '$label $level',
          style: const TextStyle(
            color: AppColors.secondaryText,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// One Genesis tier row: colored (or locked) tier badge + description.
class _GenesisRow extends StatelessWidget {
  const _GenesisRow({
    required this.effect,
    required this.color,
    required this.locked,
  });

  final HeroSkillEffect effect;
  final Color color;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: locked
                    ? [Colors.white10, Colors.black45]
                    : [color.withValues(alpha: 0.45), Colors.black54],
              ),
              border: Border.all(
                color: locked ? AppColors.cardBorder : color,
                width: 1.5,
              ),
            ),
            child: locked
                ? const Icon(Icons.lock, color: AppColors.mutedText, size: 18)
                : Text(
                    '${effect.tier}',
                    style: TextStyle(
                      color: color,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  effect.name,
                  style: TextStyle(
                    color: locked ? AppColors.mutedText : color,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                GameRichText(
                  effect.description,
                  baseStyle: const TextStyle(
                    color: AppColors.bodyText,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A circular skill icon. Skill art isn't extracted yet, so this draws a
/// themed glyph placeholder per slot, keyed off the locale-independent key.
class _SkillIcon extends StatelessWidget {
  const _SkillIcon(
      {required this.slotKey, required this.accent, this.size = 56});

  final String slotKey;
  final Color accent;
  final double size;

  static const Map<String, IconData> _glyphs = {
    'skills': Icons.auto_awesome,
    'ultimate': Icons.flash_on,
    'awaken': Icons.shield_moon,
    'genesis': Icons.brightness_7,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [accent.withValues(alpha: 0.35), Colors.black54],
        ),
        border: Border.all(color: accent, width: 1.5),
      ),
      child:
          Icon(_glyphs[slotKey] ?? Icons.star, color: accent, size: size * 0.5),
    );
  }
}

/// Public skill icon for reuse on the detail screen's slot row.
class SkillSlotIcon extends StatelessWidget {
  /// Creates a circular slot icon for [slotKey].
  const SkillSlotIcon({super.key, required this.slotKey, this.size = 56});

  /// Locale-independent slot key ("skills"/"ultimate"/"awaken"/"genesis").
  final String slotKey;

  /// Diameter in logical pixels.
  final double size;

  @override
  Widget build(BuildContext context) =>
      _SkillIcon(slotKey: slotKey, accent: slotColor(slotKey), size: size);
}
