import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/entities/soul_mirror.dart';
import '../../domain/repositories/soul_mirror_repository.dart';

/// [SoulMirrorRepository] backed by a JSON catalog under `assets/data/`.
///
/// The catalog is one array per locale (`soul_mirrors.<lang>.json`) produced by
/// `tools/extract_soul_mirrors.py` from the game's FlatBuffer configs (the
/// internal *NewRune* system). The game ships zh+en, so non-English locales
/// fall back to English. Cached in-memory.
class SoulMirrorRepositoryImpl implements SoulMirrorRepository {
  /// Creates the asset-backed soul mirror repository.
  SoulMirrorRepositoryImpl();

  final Map<String, List<SoulMirror>> _cache = {};

  @override
  Future<List<SoulMirror>> loadAll(String languageCode) async {
    final cached = _cache[languageCode];
    if (cached != null) return cached;

    final raw = await _loadLocale(languageCode);
    final list = (json.decode(raw) as List<dynamic>)
        .map((e) => SoulMirror.fromJson(e as Map<String, dynamic>))
        .toList()
      // Strongest quality first, then by power within a tier — matches how the
      // in-game catalog surfaces the best mirrors.
      ..sort((a, b) {
        final byQuality = b.quality.rank.compareTo(a.quality.rank);
        if (byQuality != 0) return byQuality;
        return b.powerScale.compareTo(a.powerScale);
      });
    _cache[languageCode] = list;
    return list;
  }

  Future<String> _loadLocale(String languageCode) async {
    final path = 'assets/data/soul_mirrors/soul_mirrors.$languageCode.json';
    try {
      return await rootBundle.loadString(path);
    } catch (_) {
      return rootBundle
          .loadString('assets/data/soul_mirrors/soul_mirrors.en.json');
    }
  }
}
