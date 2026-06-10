import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/entities/grade_cost.dart';
import '../../domain/repositories/grade_cost_repository.dart';

/// [GradeCostRepository] backed by
/// `assets/data/grade_costs/grade_costs.<lang>.json`.
///
/// English is authoritative; other locales are supplemental and fall back to
/// English when missing. Cached per locale.
class GradeCostRepositoryImpl implements GradeCostRepository {
  /// Creates the asset-backed grade-cost repository.
  GradeCostRepositoryImpl();

  final Map<String, GradeCost> _cache = {};

  @override
  Future<GradeCost> load(String languageCode) async {
    final cached = _cache[languageCode];
    if (cached != null) return cached;

    final cost = GradeCost.fromJson(
        json.decode(await _loadLocale(languageCode)) as Map<String, dynamic>);
    _cache[languageCode] = cost;
    return cost;
  }

  Future<String> _loadLocale(String languageCode) async {
    final path = 'assets/data/grade_costs/grade_costs.$languageCode.json';
    try {
      return await rootBundle.loadString(path);
    } catch (_) {
      return rootBundle
          .loadString('assets/data/grade_costs/grade_costs.en.json');
    }
  }
}
