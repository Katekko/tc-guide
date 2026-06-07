import 'package:equatable/equatable.dart';

/// The shared evolution data: the grade ladder plus the Awaken-skill unlock
/// schedule (the only slot the grade tier upgrades).
class GradeData extends Equatable {
  /// Creates grade data.
  const GradeData({required this.ladder, required this.awakenUnlock});

  /// Builds grade data from JSON.
  factory GradeData.fromJson(Map<String, dynamic> json) => GradeData(
        ladder: (json['ladder'] as List<dynamic>)
            .map((e) => HeroGrade.fromJson(e as Map<String, dynamic>))
            .toList(),
        awakenUnlock: (json['awakenUnlock'] as List<dynamic>)
            .map((e) => e as int)
            .toList(),
      );

  /// The ordered grade ladder (Rare … Opal 5★).
  final List<HeroGrade> ladder;

  /// Ladder indices at which Awaken tiers 1..4 unlock.
  final List<int> awakenUnlock;

  /// The Awaken level (count of unlocked tiers) at ladder [gradeIndex].
  int awakenLevelAt(int gradeIndex) =>
      awakenUnlock.where((i) => i <= gradeIndex).length;

  @override
  List<Object?> get props => [ladder, awakenUnlock];
}

/// One step on the shared hero evolution ladder
/// (Rare → Epic → Legend → Dawn/Eternal/Anima/Opal 1–5★).
class HeroGrade extends Equatable {
  /// Creates a grade step.
  const HeroGrade({
    required this.tier,
    required this.star,
    required this.levelCap,
    required this.label,
  });

  /// Builds a grade from JSON.
  factory HeroGrade.fromJson(Map<String, dynamic> json) => HeroGrade(
        tier: json['tier'] as String,
        star: json['star'] as int,
        levelCap: json['levelCap'] as int,
        label: json['label'] as String,
      );

  /// Tier name ("Dawn", "Anima", …).
  final String tier;

  /// Star within the tier (0 for the base Rare/Epic/Legend tiers).
  final int star;

  /// Hero level cap unlocked at this grade.
  final int levelCap;

  /// Display label ("Anima 3★").
  final String label;

  @override
  List<Object?> get props => [tier, star, levelCap, label];
}
