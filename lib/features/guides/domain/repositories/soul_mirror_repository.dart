import '../entities/soul_mirror.dart';

/// Loads the full Soul Mirror catalog for a locale.
abstract class SoulMirrorRepository {
  /// Returns every soul mirror, sorted by descending [SoulMirror.rating].
  /// Falls back to English when [languageCode] has no localized catalog.
  Future<List<SoulMirror>> loadAll(String languageCode);
}
