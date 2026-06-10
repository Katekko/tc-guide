import 'package:equatable/equatable.dart';

/// The universal SSR+ → Opal 5★ star-up cost reference (same for every hero),
/// shown as a collapsible panel on the Heroes catalog.
///
/// Loaded from per-locale `assets/data/grade_costs/grade_costs.<lang>.json`.
/// Source: Twilight Chronicles community "Character Star Up Guide".
class GradeCost extends Equatable {
  /// Creates a grade-cost reference.
  const GradeCost({
    required this.totalCopies,
    required this.duplicates,
    required this.summaryNote,
    required this.source,
    required this.fodderNote,
    required this.bands,
    required this.tips,
  });

  /// Builds the reference from the grade-costs JSON map.
  factory GradeCost.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>? ?? const {};
    return GradeCost(
      totalCopies: (summary['totalCopies'] as num?)?.toInt() ?? 0,
      duplicates: (summary['duplicates'] as num?)?.toInt() ?? 0,
      summaryNote: summary['note'] as String? ?? '',
      source: json['source'] as String? ?? '',
      fodderNote: json['fodderNote'] as String? ?? '',
      bands: (json['bands'] as List<dynamic>? ?? const [])
          .map((e) => GradeCostBand.fromJson(e as Map<String, dynamic>))
          .toList(),
      tips: (json['tips'] as List<dynamic>? ?? const [])
          .map((e) => e as String)
          .toList(),
    );
  }

  /// Total copies (duplicates + base) to reach Opal 5★.
  final int totalCopies;

  /// Duplicate copies needed (excludes the base copy).
  final int duplicates;

  /// One-line summary under the headline.
  final String summaryNote;

  /// Attribution for the data.
  final String source;

  /// Caveat about the "Light Faction" / same-faction fodder wording.
  final String fodderNote;

  /// Per-tier cost bands, in promotion order.
  final List<GradeCostBand> bands;

  /// General investment tips.
  final List<String> tips;

  @override
  List<Object?> get props =>
      [totalCopies, duplicates, summaryNote, source, fodderNote, bands, tips];
}

/// One tier band (e.g. Dawn 1→5) of the star-up cost.
class GradeCostBand extends Equatable {
  /// Creates a cost band.
  const GradeCostBand({
    required this.tier,
    required this.range,
    required this.duplicates,
    required this.needsBaseCopy,
    required this.mostExpensive,
    required this.fodder,
  });

  /// Builds a band from the grade-costs JSON map.
  factory GradeCostBand.fromJson(Map<String, dynamic> json) => GradeCostBand(
        tier: json['tier'] as String,
        range: json['range'] as String? ?? '',
        duplicates: (json['duplicates'] as num?)?.toInt() ?? 0,
        needsBaseCopy: json['needsBaseCopy'] as bool? ?? false,
        mostExpensive: json['mostExpensive'] as bool? ?? false,
        fodder: (json['fodder'] as List<dynamic>? ?? const [])
            .map((e) => e as String)
            .toList(),
      );

  /// Tier name (Dawn / Eternal / Anima / Opal).
  final String tier;

  /// Star range label (e.g. "Dawn 1★ → Dawn 5★ (6★–10★)").
  final String range;

  /// Duplicate copies consumed across this band.
  final int duplicates;

  /// Whether this band also consumes the base copy.
  final bool needsBaseCopy;

  /// Flagged as the most expensive tier to promote out of (Anima).
  final bool mostExpensive;

  /// Fodder requirement lines.
  final List<String> fodder;

  @override
  List<Object?> get props =>
      [tier, range, duplicates, needsBaseCopy, mostExpensive, fodder];
}
