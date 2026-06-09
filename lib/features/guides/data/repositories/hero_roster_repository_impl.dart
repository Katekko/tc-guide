import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/entities/hero_summary.dart';
import '../../domain/repositories/hero_roster_repository.dart';

/// [HeroRosterRepository] backed by `assets/data/heroes/index.json`.
///
/// The roster is hand-curated and grows as more heroes are extracted (each
/// entry points at an `<id>.<lang>.json` detail file via [HeroSummary.id]).
/// Results are cached in-memory after the first load.
class HeroRosterRepositoryImpl implements HeroRosterRepository {
  /// Creates the asset-backed roster repository.
  HeroRosterRepositoryImpl();

  List<HeroSummary>? _cache;

  @override
  Future<List<HeroSummary>> loadAll() async {
    final cached = _cache;
    if (cached != null) return cached;

    final raw = await rootBundle.loadString('assets/data/heroes/index.json');
    final list = (json.decode(raw) as List<dynamic>)
        .map((e) => HeroSummary.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    _cache = list;
    return list;
  }

  @override
  Future<HeroSummary?> bySlug(String slug) async {
    final all = await loadAll();
    final needle = slug.toLowerCase();
    for (final hero in all) {
      if (hero.slug.toLowerCase() == needle) return hero;
    }
    return null;
  }
}
