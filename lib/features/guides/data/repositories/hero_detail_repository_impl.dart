import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/entities/hero_detail.dart';
import '../../domain/entities/hero_grade.dart';
import '../../domain/repositories/hero_detail_repository.dart';

/// [HeroDetailRepository] backed by JSON assets under `assets/data/`.
///
/// Each hero is one file per locale (`<id>.<lang>.json`) produced by
/// `tools/extract_hero.py` (English, straight from the game's FlatBuffer
/// configs) plus hand/machine translations. The game itself ships only zh+en,
/// so non-English locales are supplemental. Results are cached in-memory.
class HeroDetailRepositoryImpl implements HeroDetailRepository {
  /// Creates the asset-backed hero repository.
  HeroDetailRepositoryImpl();

  final Map<String, HeroDetail> _cache = {};
  GradeData? _grades;

  @override
  Future<HeroDetail> load(int id, String languageCode) async {
    final key = '$id.$languageCode';
    final cached = _cache[key];
    if (cached != null) return cached;

    final raw = await _loadLocale(id, languageCode);
    final hero = HeroDetail.fromJson(json.decode(raw) as Map<String, dynamic>);
    _cache[key] = hero;
    return hero;
  }

  Future<String> _loadLocale(int id, String languageCode) async {
    final path = 'assets/data/heroes/$id.$languageCode.json';
    try {
      return await rootBundle.loadString(path);
    } catch (_) {
      // Fall back to English when this hero has no translation for the locale.
      return rootBundle.loadString('assets/data/heroes/$id.en.json');
    }
  }

  @override
  Future<GradeData> loadGrades() async {
    final cached = _grades;
    if (cached != null) return cached;
    final raw = await rootBundle.loadString('assets/data/grades.json');
    final data = GradeData.fromJson(json.decode(raw) as Map<String, dynamic>);
    _grades = data;
    return data;
  }
}
