import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tc_flutter_web/features/guides/domain/entities/soul_mirror.dart';
import 'package:tc_flutter_web/features/guides/presentation/widgets/soul_mirror_card.dart';
import 'package:tc_flutter_web/features/guides/presentation/widgets/soul_mirror_modal.dart';
import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

/// Reads the real extracted catalog straight from disk (no asset bundle needed),
/// so the data ↔ entity contract is verified against actual game data.
List<SoulMirror> _loadCatalog() {
  final raw = File('assets/data/soul_mirrors/soul_mirrors.en.json')
      .readAsStringSync();
  return (json.decode(raw) as List<dynamic>)
      .map((e) => SoulMirror.fromJson(e as Map<String, dynamic>))
      .toList();
}

void main() {
  group('Soul Mirror data contract', () {
    final mirrors = _loadCatalog();

    test('every record parses into a SoulMirror', () {
      expect(mirrors, hasLength(69));
      // No mirror loses its identity (name/type resolved or gracefully defaulted).
      expect(mirrors.every((m) => m.name.isNotEmpty), isTrue);
    });

    test('Yin matches the in-game detail (DPS / Epic / Final DMG scaling)', () {
      final yin = mirrors.firstWhere((m) => m.name == 'Yin');
      expect(yin.type, SoulMirrorType.dps);
      expect(yin.quality, SoulMirrorQuality.epic);
      expect(yin.heroId, isNotNull);
      expect(yin.tags, contains('final-dmg'));
      // Activate + 1..5 star = 6 tiers, base first.
      expect(yin.skill, hasLength(6));
      expect(yin.skill.first.star, 0);
      expect(yin.skill.first.effect, contains('Final DMG'));
      expect(yin.skill.last.effect, contains('5%'));
      expect(yin.activation, isNotEmpty);
    });

    test('Anima mirrors are flagged and hero-independent', () {
      final bull = mirrors.firstWhere((m) => m.name == 'Mystic Bull');
      expect(bull.isAnima, isTrue);
      expect(bull.quality, SoulMirrorQuality.anima);
      expect(bull.heroId, isNull);
      expect(bull.tags, contains('shield'));
    });

    test('auto-tags line up with the known tier-list categories', () {
      Iterable<String> tagsOf(String name) =>
          mirrors.firstWhere((m) => m.name == name).tags;
      expect(tagsOf('Sherry'), contains('bleed'));
      expect(tagsOf('Ling'), contains('infect'));
      expect(tagsOf('Luna'), contains('aoe'));
    });
  });

  group('Soul Mirror widgets', () {
    const sample = SoulMirror(
      id: 72014,
      name: 'Yin',
      type: SoulMirrorType.dps,
      quality: SoulMirrorQuality.epic,
      powerScale: 166,
      isAnima: false,
      isRare: false,
      heroId: 35009,
      activation: ['Final DMG +2%.'],
      skill: [
        SoulMirrorSkillTier(star: 0, effect: 'Final DMG +2%.'),
        SoulMirrorSkillTier(star: 5, effect: 'Final DMG +5%.'),
      ],
      baseStats: SoulMirrorStats(atk: 10, def: 3, hp: 100),
      tags: ['final-dmg'],
    );

    Widget host(Widget child) => MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: Center(child: child)),
        );

    testWidgets('card renders name + humanized tag and opens the modal',
        (tester) async {
      await tester.pumpWidget(host(
        Builder(
          builder: (context) => SoulMirrorCard(
            mirror: sample,
            onTap: () => showSoulMirrorModal(context, sample),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Yin'), findsOneWidget);
      expect(find.text('Final DMG'), findsOneWidget); // humanized tag pill

      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      // Modal shows the per-star scaling and stat bonus.
      expect(find.text('Final DMG +5%.'), findsOneWidget);
      expect(find.textContaining('Power: 166'), findsOneWidget);
    });
  });
}
