import 'package:equatable/equatable.dart';

/// A curated Soul Mirror tier ranking for a single hero, produced by the
/// `mirror-expert` agent (see `docs/mirror-mechanics.md`) and stored at
/// `assets/data/heroes/<id>.mirrors.json`. Drives the per-hero "Recommended
/// Mirrors" tier list on the hero page.
class HeroMirrorRanking extends Equatable {
  /// Creates a ranking.
  const HeroMirrorRanking({
    required this.heroId,
    required this.heroName,
    required this.profile,
    required this.picks,
  });

  /// Builds a ranking from the agent's JSON output.
  factory HeroMirrorRanking.fromJson(Map<String, dynamic> json) =>
      HeroMirrorRanking(
        heroId: (json['heroId'] as num).toInt(),
        heroName: json['heroName'] as String? ?? '',
        profile: json['profile'] as String? ?? '',
        picks: (json['ranking'] as List<dynamic>? ?? const [])
            .map((e) => HeroMirrorPick.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Hero id this ranking is for.
  final int heroId;

  /// Hero display name.
  final String heroName;

  /// 2–3 sentence mechanic profile explaining what the hero wants from mirrors.
  final String profile;

  /// Every ranked mirror, ordered best tier first.
  final List<HeroMirrorPick> picks;

  @override
  List<Object?> get props => [heroId, heroName, profile, picks];
}

/// One mirror's placement in a hero's ranking.
class HeroMirrorPick extends Equatable {
  /// Creates a pick.
  const HeroMirrorPick({
    required this.mirrorId,
    required this.name,
    required this.tier,
    required this.reason,
    this.recommendedStar,
  });

  /// Builds a pick from JSON.
  factory HeroMirrorPick.fromJson(Map<String, dynamic> json) => HeroMirrorPick(
        mirrorId: (json['mirrorId'] as num).toInt(),
        name: json['name'] as String? ?? '',
        tier: MirrorTier.fromKey(json['tier'] as String?),
        reason: json['reason'] as String? ?? '',
        recommendedStar: (json['recommendedStar'] as num?)?.toInt(),
      );

  /// The mirror's catalog id (joins to a `SoulMirror`).
  final int mirrorId;

  /// Mirror name (denormalized for resilience if the catalog lacks the id).
  final String name;

  /// Tier bucket (S best → F trash).
  final MirrorTier tier;

  /// One-sentence rationale for this placement on this hero.
  final String reason;

  /// Star at which the mirror becomes worth using (a breakpoint): `0` = useful
  /// immediately, a positive value = only from that star, `null` = star-agnostic.
  final int? recommendedStar;

  @override
  List<Object?> get props => [mirrorId, name, tier, reason, recommendedStar];
}

/// Tier buckets for a hero's mirror ranking, best → worst.
enum MirrorTier {
  /// Best-in-slot.
  s,

  /// Excellent.
  a,

  /// Solid filler.
  b,

  /// Marginal.
  c,

  /// Weak.
  d,

  /// Trash / anti-synergy.
  f,

  /// Unparseable tier.
  unknown;

  /// Maps the JSON tier letter (any case) to an enum value.
  static MirrorTier fromKey(String? key) {
    switch (key?.toUpperCase()) {
      case 'S':
        return MirrorTier.s;
      case 'A':
        return MirrorTier.a;
      case 'B':
        return MirrorTier.b;
      case 'C':
        return MirrorTier.c;
      case 'D':
        return MirrorTier.d;
      case 'F':
        return MirrorTier.f;
      default:
        return MirrorTier.unknown;
    }
  }

  /// Single-letter label shown in the tier badge.
  String get label => this == MirrorTier.unknown ? '?' : name.toUpperCase();
}
