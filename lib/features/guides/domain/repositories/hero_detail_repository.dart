import '../entities/hero_detail.dart';
import '../entities/hero_grade.dart';

/// Loads full hero data (extracted from the game) bundled as JSON assets.
abstract class HeroDetailRepository {
  /// Loads the [HeroDetail] for the given TC hero [id] in [languageCode]
  /// (e.g. `en`, `pt`), falling back to English when a locale file is missing.
  Future<HeroDetail> load(int id, String languageCode);

  /// Loads the shared hero evolution data (grade ladder + Awaken schedule).
  Future<GradeData> loadGrades();
}
