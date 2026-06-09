import 'package:flutter/material.dart';

import 'package:tc_flutter_web/core/theme/app_colors.dart';
import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import '../../domain/entities/soul_mirror.dart';
import 'soul_mirror_kit.dart';

/// Shows the Soul Mirror detail modal for [mirror], mirroring the in-game popup:
/// header, activation effect, per-star skill scaling, stat bonus and tags.
Future<void> showSoulMirrorModal(BuildContext context, SoulMirror mirror) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black87,
    builder: (_) => _SoulMirrorModal(mirror: mirror),
  );
}

class _SoulMirrorModal extends StatelessWidget {
  const _SoulMirrorModal({required this.mirror});

  final SoulMirror mirror;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final style = SoulMirrorTypeStyle.of(mirror.type);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: const Color(0xf21a2336),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: style.color.withValues(alpha: 0.55)),
          boxShadow: const [
            BoxShadow(color: Colors.black54, blurRadius: 24, spreadRadius: 2),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(mirror: mirror, style: style, l: l),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (mirror.activation.isNotEmpty) ...[
                      _SectionLabel(l.soulMirrorActivationLabel,
                          color: style.color),
                      const SizedBox(height: 6),
                      for (final line in mirror.activation)
                        _ActivationLine(line),
                      const SizedBox(height: 16),
                    ],
                    if (mirror.skill.isNotEmpty) ...[
                      _SectionLabel(l.soulMirrorSkillLabel, color: style.color),
                      const SizedBox(height: 8),
                      _SkillTable(
                          skill: mirror.skill, accent: style.color, l: l),
                    ],
                    if (_hasStats) ...[
                      const SizedBox(height: 16),
                      _SectionLabel(l.soulMirrorStatsLabel, color: style.color),
                      const SizedBox(height: 8),
                      _StatBonus(stats: mirror.baseStats),
                    ],
                    if (mirror.tags.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final t in mirror.tags)
                            _Pill(humanizeTag(t), style.color),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _hasStats =>
      mirror.baseStats.atk > 0 ||
      mirror.baseStats.def > 0 ||
      mirror.baseStats.hp > 0;
}

class _Header extends StatelessWidget {
  const _Header({required this.mirror, required this.style, required this.l});

  final SoulMirror mirror;
  final SoulMirrorTypeStyle style;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [style.color.withValues(alpha: 0.35), Colors.black54],
            ),
            border: Border.all(color: style.color, width: 1.5),
          ),
          child: Icon(style.icon, color: style.color, size: 26),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      mirror.name,
                      style: const TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _Pill(
                    SoulMirrorQualityStyle.label(mirror.quality, l),
                    SoulMirrorQualityStyle.of(mirror.quality).color,
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  Text(
                    SoulMirrorTypeStyle.label(mirror.type, l),
                    style: TextStyle(
                      color: style.color,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (mirror.powerScale > 0) ...[
                    const SizedBox(width: 10),
                    Text(
                      '${l.soulMirrorPowerLabel}: ${mirror.powerScale}',
                      style: const TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, {required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      '[$text]',
      style: TextStyle(
        color: color,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ActivationLine extends StatelessWidget {
  const _ActivationLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.bodyText,
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
  }
}

/// Per-star skill scaling rows. Star 0 renders as the localized "Activate"
/// label; 1..N render as star pips.
class _SkillTable extends StatelessWidget {
  const _SkillTable(
      {required this.skill, required this.accent, required this.l});

  final List<SoulMirrorSkillTier> skill;
  final Color accent;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final tier in skill)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 74,
                  child: tier.star == 0
                      ? Text(
                          l.soulMirrorActivateLabel,
                          style: TextStyle(
                            color: accent,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : Text(
                          '${tier.star}★',
                          style: TextStyle(
                            color: accent,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
                Expanded(
                  child: Text(
                    tier.effect,
                    style: const TextStyle(
                      color: AppColors.bodyText,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _StatBonus extends StatelessWidget {
  const _StatBonus({required this.stats});

  final SoulMirrorStats stats;

  @override
  Widget build(BuildContext context) {
    final entries = <(String, int)>[
      if (stats.hp > 0) ('HP', stats.hp),
      if (stats.atk > 0) ('ATK', stats.atk),
      if (stats.def > 0) ('DEF', stats.def),
    ];
    return Wrap(
      spacing: 16,
      runSpacing: 6,
      children: [
        for (final (label, value) in entries)
          Text.rich(TextSpan(children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: '+$value',
              style: const TextStyle(
                color: AppColors.primaryText,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ])),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text, this.color);

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
