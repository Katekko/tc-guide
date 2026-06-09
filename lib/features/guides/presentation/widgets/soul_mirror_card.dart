import 'package:flutter/material.dart';

import 'package:tc_flutter_web/core/theme/app_colors.dart';
import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import '../../domain/entities/soul_mirror.dart';
import 'soul_mirror_kit.dart';

/// A compact, tappable Soul Mirror tile: portrait + quality border, name, type
/// badge, power, and up to a few mechanic-tag pills. Fixed width so a [Wrap]
/// can lay them out without grid aspect-ratio overflow.
class SoulMirrorCard extends StatelessWidget {
  /// Creates a card for [mirror].
  const SoulMirrorCard({required this.mirror, required this.onTap, super.key});

  /// The mirror to render.
  final SoulMirror mirror;

  /// Tap handler (opens the detail modal).
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final type = SoulMirrorTypeStyle.of(mirror.type);
    final quality = SoulMirrorQualityStyle.of(mirror.quality);
    return SizedBox(
      width: 158,
      child: Material(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: quality.color.withValues(alpha: 0.5)),
            ),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Portrait(mirror: mirror, type: type, quality: quality, l: l),
                const SizedBox(height: 10),
                Text(
                  mirror.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(type.icon, color: type.color, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      SoulMirrorTypeStyle.label(mirror.type, l),
                      style: TextStyle(
                        color: type.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (mirror.powerScale > 0) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.bolt,
                          size: 13, color: AppColors.mutedText),
                      Text(
                        '${mirror.powerScale}',
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
                if (mirror.tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      for (final tag in mirror.tags.take(3)) _TagPill(tag: tag),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Portrait extends StatelessWidget {
  const _Portrait({
    required this.mirror,
    required this.type,
    required this.quality,
    required this.l,
  });

  final SoulMirror mirror;
  final SoulMirrorTypeStyle type;
  final SoulMirrorQualityStyle quality;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: [
          Positioned.fill(child: _portraitInner()),
          Positioned(
            top: 6,
            left: 6,
            child: _Badge(
              label: SoulMirrorQualityStyle.label(mirror.quality, l),
              color: quality.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _portraitInner() {
    // Per-mirror icon extracted from the APK (covers hero + Anima mirrors);
    // falls back to a type-tinted initial for the rare mirror with no icon.
    final image = Image.asset(
      'assets/img/soul_mirrors/${mirror.id}.png',
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) =>
          _Placeholder(color: type.color, name: mirror.name),
    );
    return ClipRRect(borderRadius: BorderRadius.circular(10), child: image);
  }
}

/// Type-tinted fallback shown when a mirror has no extracted portrait: the
/// mirror's initial over a gradient.
class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.color, required this.name});

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
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          name.isEmpty ? '?' : name.characters.first.toUpperCase(),
          style: TextStyle(
            color: color,
            fontSize: 34,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.tag});

  final String tag;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.selectedBackground,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Text(
        humanizeTag(tag),
        style: const TextStyle(
          color: AppColors.secondaryText,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
