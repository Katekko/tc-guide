import '../entities/hero_summary.dart';

/// Loads the hero roster that backs the Heroes catalog (`/heroes`) and resolves
/// the shareable slug used by `/heroes/:name` to a concrete hero.
abstract class HeroRosterRepository {
  /// Returns every roster entry, sorted by display name.
  Future<List<HeroSummary>> loadAll();

  /// Resolves a route [slug] (e.g. `jeanne`) to its roster entry, or `null`
  /// when no hero matches.
  Future<HeroSummary?> bySlug(String slug);
}
