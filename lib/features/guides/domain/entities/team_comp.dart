import 'package:equatable/equatable.dart';

/// A curated team composition built around one debuff engine (e.g. the
/// [Holy Seal] light core), as shown on the Team Comps page.
///
/// Loaded from per-locale `assets/data/team_comps/comps.<lang>.json`. Hero
/// display data (name/portrait/faction) is resolved at render time through the
/// roster index, so the comp file only stores hero ids.
class TeamComp extends Equatable {
  /// Creates a team composition.
  const TeamComp({
    required this.id,
    required this.tier,
    required this.name,
    required this.engine,
    required this.summary,
    required this.whyItWorks,
    required this.mirrorNote,
    required this.variants,
  });

  /// Builds a comp from the comps JSON map.
  factory TeamComp.fromJson(Map<String, dynamic> json) => TeamComp(
        id: json['id'] as String,
        tier: json['tier'] as String,
        name: json['name'] as String,
        engine: json['engine'] as String,
        summary: json['summary'] as String? ?? '',
        whyItWorks: json['whyItWorks'] as String? ?? '',
        mirrorNote: json['mirrorNote'] as String? ?? '',
        variants: (json['variants'] as List<dynamic>)
            .map((e) => TeamCompVariant.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Stable identifier (e.g. `holy-seal-renais`).
  final String id;

  /// Tier badge label (S/A/B…).
  final String tier;

  /// Display name (e.g. "Holy Seal — Renais Core").
  final String name;

  /// The named debuff engine the comp stacks (e.g. "Holy Seal").
  final String engine;

  /// One-line teaser under the card title.
  final String summary;

  /// The "why it works" explanation paragraph.
  final String whyItWorks;

  /// Pointer to the carry's mirror recommendations.
  final String mirrorNote;

  /// Lineup variants (endgame / budget), in display order.
  final List<TeamCompVariant> variants;

  @override
  List<Object?> get props =>
      [id, tier, name, engine, summary, whyItWorks, mirrorNote, variants];
}

/// One lineup variant of a [TeamComp] (e.g. the budget version).
class TeamCompVariant extends Equatable {
  /// Creates a comp variant.
  const TeamCompVariant({required this.key, required this.slots});

  /// Builds a variant from the comps JSON map.
  factory TeamCompVariant.fromJson(Map<String, dynamic> json) =>
      TeamCompVariant(
        key: json['key'] as String,
        slots: (json['slots'] as List<dynamic>)
            .map((e) => TeamCompSlot.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Locale-independent variant key (`endgame` or `budget`), mapped to a
  /// localized toggle label by the UI.
  final String key;

  /// The 6 deployed heroes, ordered by battle slot.
  final List<TeamCompSlot> slots;

  @override
  List<Object?> get props => [key, slots];
}

/// One deployed hero within a [TeamCompVariant].
class TeamCompSlot extends Equatable {
  /// Creates a comp slot.
  const TeamCompSlot({
    required this.slot,
    required this.line,
    required this.heroId,
    required this.role,
    required this.why,
  });

  /// Builds a slot from the comps JSON map.
  factory TeamCompSlot.fromJson(Map<String, dynamic> json) => TeamCompSlot(
        slot: (json['slot'] as num).toInt(),
        line: json['line'] as String,
        heroId: (json['heroId'] as num).toInt(),
        role: json['role'] as String,
        why: json['why'] as String? ?? '',
      );

  /// Battle slot number (1 = front, 2–3 = mid, 4–6 = back).
  final int slot;

  /// Battle line (`front`, `mid` or `back`), used to place the portrait
  /// in the grid column.
  final String line;

  /// TC hero id, resolved against the roster index for display data.
  final int heroId;

  /// Localized role label shown under the portrait (e.g. "Carry").
  final String role;

  /// Localized one-liner explaining why this hero fills the slot.
  final String why;

  @override
  List<Object?> get props => [slot, line, heroId, role, why];
}
