import 'package:flutter/material.dart';

import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import '../../domain/entities/soul_mirror.dart';

/// Visual metadata for a [SoulMirrorType]: accent color, glyph, and the
/// localized label. Keeps the card and modal in visual sync.
class SoulMirrorTypeStyle {
  const SoulMirrorTypeStyle(this.color, this.icon);

  /// Accent color echoing the in-game type badge.
  final Color color;

  /// Glyph stand-in (the game's sword/shield art isn't extracted).
  final IconData icon;

  /// Style for [type].
  static SoulMirrorTypeStyle of(SoulMirrorType type) {
    switch (type) {
      case SoulMirrorType.dps:
        return const SoulMirrorTypeStyle(Color(0xffe5677a), Icons.flash_on);
      case SoulMirrorType.def:
        return const SoulMirrorTypeStyle(Color(0xff5fa8ff), Icons.shield);
      case SoulMirrorType.control:
        return const SoulMirrorTypeStyle(Color(0xffa06fff), Icons.ac_unit);
      case SoulMirrorType.support:
        return const SoulMirrorTypeStyle(Color(0xff4fd6a0), Icons.favorite);
      case SoulMirrorType.unknown:
        return const SoulMirrorTypeStyle(Color(0xff8190aa), Icons.help_outline);
    }
  }

  /// Localized label for [type].
  static String label(SoulMirrorType type, AppLocalizations l) {
    switch (type) {
      case SoulMirrorType.dps:
        return l.soulMirrorTypeDps;
      case SoulMirrorType.def:
        return l.soulMirrorTypeDef;
      case SoulMirrorType.control:
        return l.soulMirrorTypeControl;
      case SoulMirrorType.support:
        return l.soulMirrorTypeSupport;
      case SoulMirrorType.unknown:
        return '—';
    }
  }
}

/// Visual metadata for a [SoulMirrorQuality]: rarity color + localized label.
/// The color tints the card border, echoing the in-game quality tabs.
class SoulMirrorQualityStyle {
  const SoulMirrorQualityStyle(this.color);

  /// Rarity accent color.
  final Color color;

  /// Style for [quality].
  static SoulMirrorQualityStyle of(SoulMirrorQuality quality) {
    switch (quality) {
      case SoulMirrorQuality.epic:
        return const SoulMirrorQualityStyle(Color(0xff5fc77e));
      case SoulMirrorQuality.legendary:
        return const SoulMirrorQualityStyle(Color(0xff5fa8ff));
      case SoulMirrorQuality.eternal:
        return const SoulMirrorQualityStyle(Color(0xffb07bff));
      case SoulMirrorQuality.anima:
        return const SoulMirrorQualityStyle(Color(0xffe0b24c));
      case SoulMirrorQuality.rare:
        return const SoulMirrorQualityStyle(Color(0xffe5677a));
      case SoulMirrorQuality.unknown:
        return const SoulMirrorQualityStyle(Color(0xff2a3856));
    }
  }

  /// Localized label for [quality].
  static String label(SoulMirrorQuality quality, AppLocalizations l) {
    switch (quality) {
      case SoulMirrorQuality.epic:
        return l.soulMirrorQualityEpic;
      case SoulMirrorQuality.legendary:
        return l.soulMirrorQualityLegendary;
      case SoulMirrorQuality.eternal:
        return l.soulMirrorQualityEternal;
      case SoulMirrorQuality.anima:
        return l.soulMirrorAnimaLabel;
      case SoulMirrorQuality.rare:
        return l.soulMirrorRareLabel;
      case SoulMirrorQuality.unknown:
        return '—';
    }
  }
}

/// Acronyms that should stay fully uppercase when humanizing a tag slug.
const Set<String> _tagAcronyms = {
  'dmg',
  'aoe',
  'atk',
  'def',
  'hp',
  'dps',
  'ult',
  'batk',
  'red',
  'crit',
};

/// Turns an auto-derived tag slug ("final-dmg") into a display label
/// ("Final DMG"). Tags come straight from the extractor, so there are no l10n
/// keys for them yet — this is the single place that renders them.
String humanizeTag(String slug) {
  final parts = slug.split(RegExp('[-_ ]+')).where((p) => p.isNotEmpty);
  return parts
      .map((p) =>
          _tagAcronyms.contains(p) ? p.toUpperCase() : '${p[0].toUpperCase()}${p.substring(1)}')
      .join(' ');
}
