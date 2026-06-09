import 'package:equatable/equatable.dart';

/// A lightweight hero roster entry used by the Heroes catalog (`/heroes`).
///
/// Unlike the full [HeroDetail], this carries only what the grid and routing
/// need: a shareable [slug], display [name], class/rarity for filters and
/// badges, and the portrait asset. Loaded from `assets/data/heroes/index.json`.
class HeroSummary extends Equatable {
  /// Creates a roster entry.
  const HeroSummary({
    required this.id,
    required this.slug,
    required this.name,
    required this.heroClass,
    required this.faction,
    required this.rarity,
    required this.portrait,
    this.roles = const [],
  });

  /// Builds a summary from the index JSON map.
  factory HeroSummary.fromJson(Map<String, dynamic> json) => HeroSummary(
        id: (json['id'] as num).toInt(),
        slug: json['slug'] as String,
        name: json['name'] as String,
        heroClass: json['heroClass'] as String? ?? 'Universal',
        faction: json['faction'] as String? ?? 'Unknown',
        rarity: json['rarity'] as String? ?? 'UR',
        portrait: json['portrait'] as String,
        roles: (json['roles'] as List<dynamic>? ?? const [])
            .map((e) => e as String)
            .toList(),
      );

  /// TC hero id (e.g. 55007), used to load full detail + the Spine rig.
  final int id;

  /// URL-friendly identifier for the `/heroes/:name` route (e.g. `jeanne`).
  final String slug;

  /// Display name shown on the catalog tile.
  final String name;

  /// Combat class (Guard / Assassin / Assault / Control / Support …).
  final String heroClass;

  /// Faction / camp (Holylight, Arcane Web, Kindred, Demonhunter, Sanctuary,
  /// Fiend, Otherworld) — mirrors the in-game codex Race grouping.
  final String faction;

  /// Rarity tier (UR, UR+, …), shown as a badge and used for filtering.
  final String rarity;

  /// Portrait asset path for the catalog tile.
  final String portrait;

  /// Role tags (e.g. "Core DPS"), shown as a subtitle.
  final List<String> roles;

  @override
  List<Object?> get props =>
      [id, slug, name, heroClass, faction, rarity, portrait, roles];
}
