import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/entities/hero_mirror_ranking.dart';
import '../../domain/repositories/hero_mirror_repository.dart';

/// [HeroMirrorRepository] backed by per-hero JSON under `assets/data/heroes/`.
///
/// Each curated hero has a `<id>.mirrors.json` produced by the `mirror-expert`
/// agent. Heroes without a file return `null` (the page then falls back to the
/// hero's bonded-mirror hint). Results are cached in-memory; a missing file is
/// cached as `null` so we don't re-attempt the asset load on every rebuild.
class HeroMirrorRepositoryImpl implements HeroMirrorRepository {
  /// Creates the asset-backed hero mirror ranking repository.
  HeroMirrorRepositoryImpl();

  final Map<int, HeroMirrorRanking?> _cache = {};

  @override
  Future<HeroMirrorRanking?> load(int heroId) async {
    if (_cache.containsKey(heroId)) return _cache[heroId];

    HeroMirrorRanking? ranking;
    try {
      final raw =
          await rootBundle.loadString('assets/data/heroes/$heroId.mirrors.json');
      ranking = HeroMirrorRanking.fromJson(
          json.decode(raw) as Map<String, dynamic>);
    } catch (_) {
      ranking = null; // not curated yet
    }
    _cache[heroId] = ranking;
    return ranking;
  }
}
