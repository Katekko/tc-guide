import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/entities/team_comp.dart';
import '../../domain/repositories/team_comp_repository.dart';

/// [TeamCompRepository] backed by `assets/data/team_comps/comps.<lang>.json`.
///
/// English is the authoritative locale; other locales are supplemental and
/// fall back to English when missing. Results are cached per locale.
class TeamCompRepositoryImpl implements TeamCompRepository {
  /// Creates the asset-backed team comp repository.
  TeamCompRepositoryImpl();

  final Map<String, List<TeamComp>> _cache = {};

  @override
  Future<List<TeamComp>> loadAll(String languageCode) async {
    final cached = _cache[languageCode];
    if (cached != null) return cached;

    final raw = json.decode(await _loadLocale(languageCode));
    final comps = ((raw as Map<String, dynamic>)['comps'] as List<dynamic>)
        .map((e) => TeamComp.fromJson(e as Map<String, dynamic>))
        .toList();
    _cache[languageCode] = comps;
    return comps;
  }

  Future<String> _loadLocale(String languageCode) async {
    final path = 'assets/data/team_comps/comps.$languageCode.json';
    try {
      return await rootBundle.loadString(path);
    } catch (_) {
      return rootBundle.loadString('assets/data/team_comps/comps.en.json');
    }
  }
}
