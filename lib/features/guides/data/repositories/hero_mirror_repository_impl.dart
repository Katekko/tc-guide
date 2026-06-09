import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/entities/hero_mirror_ranking.dart';
import '../../domain/repositories/hero_mirror_repository.dart';

/// [HeroMirrorRepository] backed by per-hero JSON under `assets/data/heroes/`.
///
/// Each curated hero has per-locale `<id>.mirrors.<lang>.json` files produced by
/// the `mirror-expert` agent (English is authoritative; other locales are
/// supplemental and fall back to English). Heroes without a file return `null`
/// (the page then falls back to the hero's bonded-mirror hint). Results are
/// cached per (hero, locale); a missing file is cached as `null` so we don't
/// re-attempt the asset load on every rebuild.
class HeroMirrorRepositoryImpl implements HeroMirrorRepository {
  /// Creates the asset-backed hero mirror ranking repository.
  HeroMirrorRepositoryImpl();

  final Map<String, HeroMirrorRanking?> _cache = {};

  @override
  Future<HeroMirrorRanking?> load(int heroId, String languageCode) async {
    final key = '$heroId.$languageCode';
    if (_cache.containsKey(key)) return _cache[key];

    HeroMirrorRanking? ranking;
    try {
      ranking = HeroMirrorRanking.fromJson(
          json.decode(await _loadLocale(heroId, languageCode))
              as Map<String, dynamic>);
    } catch (_) {
      ranking = null; // not curated yet
    }
    _cache[key] = ranking;
    return ranking;
  }

  Future<String> _loadLocale(int heroId, String languageCode) async {
    final path = 'assets/data/heroes/$heroId.mirrors.$languageCode.json';
    try {
      return await rootBundle.loadString(path);
    } catch (_) {
      // Fall back to English when this hero has no ranking for the locale.
      return rootBundle
          .loadString('assets/data/heroes/$heroId.mirrors.en.json');
    }
  }
}
