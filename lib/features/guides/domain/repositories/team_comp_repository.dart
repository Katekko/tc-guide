import '../entities/team_comp.dart';

/// Loads the curated team compositions shown on `/docs/team-comps`.
abstract class TeamCompRepository {
  /// Returns every comp for [languageCode], falling back to English when the
  /// locale has no comps file.
  Future<List<TeamComp>> loadAll(String languageCode);
}
