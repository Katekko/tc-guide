import '../entities/hero_mirror_ranking.dart';

/// Loads the curated per-hero Soul Mirror tier ranking, when one exists.
abstract class HeroMirrorRepository {
  /// Returns the ranking for [heroId], or `null` when the hero has not been
  /// curated yet (no `assets/data/heroes/<id>.mirrors.json`).
  Future<HeroMirrorRanking?> load(int heroId);
}
