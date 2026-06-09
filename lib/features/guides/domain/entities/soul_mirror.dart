import 'package:equatable/equatable.dart';

/// A mirror's flat stat bonus, shown in the detail modal.
class SoulMirrorStats extends Equatable {
  /// Creates a stat block.
  const SoulMirrorStats({required this.atk, required this.def, required this.hp});

  /// Builds stats from JSON, tolerating missing fields.
  factory SoulMirrorStats.fromJson(Map<String, dynamic> json) =>
      SoulMirrorStats(
        atk: (json['atk'] as num?)?.toInt() ?? 0,
        def: (json['def'] as num?)?.toInt() ?? 0,
        hp: (json['hp'] as num?)?.toInt() ?? 0,
      );

  /// Flat ATK bonus.
  final int atk;

  /// Flat DEF bonus.
  final int def;

  /// Flat HP bonus.
  final int hp;

  @override
  List<Object?> get props => [atk, def, hp];
}

/// One star tier of a mirror's Soul Mirror Skill (Activate → 1★ … 5★).
class SoulMirrorSkillTier extends Equatable {
  /// Creates a skill tier.
  const SoulMirrorSkillTier({required this.star, required this.effect});

  /// Star level. `0` is the base "Activate" tier.
  final int star;

  /// The effect text at this star (e.g. "Final DMG +2.5%").
  final String effect;

  @override
  List<Object?> get props => [star, effect];
}

/// A single Soul Mirror, mirroring the in-game detail popup.
///
/// Mirrors are tied to a hero (same name) or are non-hero "Anima" mirrors.
/// Produced by `tools/extract_soul_mirrors.py` (the internal *NewRune* system)
/// into `assets/data/soul_mirrors/soul_mirrors.<lang>.json`.
class SoulMirror extends Equatable {
  /// Creates a soul mirror.
  const SoulMirror({
    required this.id,
    required this.name,
    required this.type,
    required this.quality,
    required this.powerScale,
    required this.isAnima,
    required this.isRare,
    required this.activation,
    required this.skill,
    required this.baseStats,
    required this.tags,
    this.heroId,
  });

  /// Builds a mirror from the extracted JSON map. Lenient about absent fields
  /// so partial data (e.g. the newest, text-less mirrors) never crashes the grid.
  factory SoulMirror.fromJson(Map<String, dynamic> json) {
    final skillJson = json['skill'] as Map<String, dynamic>?;
    final tiers = <SoulMirrorSkillTier>[];
    final base = skillJson?['baseEffect'] as String?;
    if (base != null && base.isNotEmpty) {
      tiers.add(SoulMirrorSkillTier(star: 0, effect: base));
    }
    for (final e in (skillJson?['perStar'] as List<dynamic>? ?? const [])) {
      final m = e as Map<String, dynamic>;
      final effect = m['effectText'] as String?;
      if (effect != null && effect.isNotEmpty) {
        tiers.add(
          SoulMirrorSkillTier(star: (m['star'] as num).toInt(), effect: effect),
        );
      }
    }

    return SoulMirror(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '???',
      type: SoulMirrorType.fromKey(json['type'] as String?),
      quality: SoulMirrorQuality.fromKey(json['quality'] as String?),
      powerScale: (json['powerScale'] as num?)?.toInt() ?? 0,
      isAnima: json['isAnima'] as bool? ?? false,
      isRare: json['isRare'] as bool? ?? false,
      heroId: (json['heroId'] as num?)?.toInt(),
      activation: (json['activationEffect'] as List<dynamic>? ?? const [])
          .map((e) => e as String)
          .toList(),
      skill: tiers,
      baseStats: SoulMirrorStats.fromJson(
          json['baseStats'] as Map<String, dynamic>? ?? const {}),
      tags: (json['tags'] as List<dynamic>? ?? const [])
          .map((e) => e as String)
          .toList(),
    );
  }

  /// Internal mirror id (e.g. 72014).
  final int id;

  /// Display name, same as the bonded hero ("Yin").
  final String name;

  /// Combat role type (DPS / DEF / Control / Support).
  final SoulMirrorType type;

  /// Quality tier (Epic → Rare), mirroring the in-game quality tabs.
  final SoulMirrorQuality quality;

  /// Cumulative per-star power-display scale — a data-backed strength proxy
  /// used for ranking (the in-game integer "Rating" isn't stored anywhere).
  final int powerScale;

  /// Whether this is a non-hero Anima mirror.
  final bool isAnima;

  /// Whether this is a Rare (top-tier) mirror.
  final bool isRare;

  /// Bonded hero id, when this mirror maps to a known hero.
  final int? heroId;

  /// Activation effect lines (the "Activate" skill text).
  final List<String> activation;

  /// Per-star Soul Mirror Skill scaling (star 0 = base "Activate").
  final List<SoulMirrorSkillTier> skill;

  /// Flat stat bonuses.
  final SoulMirrorStats baseStats;

  /// Auto-derived mechanic tags ("crit", "heal", "infect", "final-dmg", …).
  final List<String> tags;

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        quality,
        powerScale,
        isAnima,
        isRare,
        heroId,
        activation,
        skill,
        baseStats,
        tags,
      ];
}

/// The four in-game mirror types. Drives the type filter and badge color.
enum SoulMirrorType {
  /// Damage dealer (sword badge).
  dps,

  /// Defensive / guard (shield badge).
  def,

  /// Crowd control.
  control,

  /// Support / healer.
  support,

  /// Type could not be resolved from the data.
  unknown;

  /// Maps the extractor's lowercase key to an enum value.
  static SoulMirrorType fromKey(String? key) {
    switch (key) {
      case 'dps':
        return SoulMirrorType.dps;
      case 'def':
        return SoulMirrorType.def;
      case 'control':
        return SoulMirrorType.control;
      case 'support':
        return SoulMirrorType.support;
      default:
        return SoulMirrorType.unknown;
    }
  }
}

/// Quality tiers, ordered weakest → strongest (drives sort + rarity color).
enum SoulMirrorQuality {
  /// Lowest tier.
  epic,

  /// Second tier.
  legendary,

  /// Third tier.
  eternal,

  /// Non-hero Anima tier.
  anima,

  /// Top tier.
  rare,

  /// Quality could not be resolved.
  unknown;

  /// Maps the extractor's lowercase key to an enum value.
  static SoulMirrorQuality fromKey(String? key) {
    switch (key) {
      case 'epic':
        return SoulMirrorQuality.epic;
      case 'legendary':
        return SoulMirrorQuality.legendary;
      case 'eternal':
        return SoulMirrorQuality.eternal;
      case 'anima':
        return SoulMirrorQuality.anima;
      case 'rare':
        return SoulMirrorQuality.rare;
      default:
        return SoulMirrorQuality.unknown;
    }
  }

  /// Sort rank (higher = stronger / later tab).
  int get rank => index;
}
