import '../entities/grade_cost.dart';

/// Loads the universal SSR+ star-up cost reference shown on the Heroes catalog.
abstract class GradeCostRepository {
  /// Returns the cost reference for [languageCode], falling back to English.
  Future<GradeCost> load(String languageCode);
}
