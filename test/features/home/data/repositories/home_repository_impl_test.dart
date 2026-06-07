import 'package:flutter_test/flutter_test.dart';
import 'package:tc_flutter_web/core/router/app_routes.dart';
import 'package:tc_flutter_web/features/home/data/repositories/home_repository_impl.dart';
import 'package:tc_flutter_web/l10n/generated/app_localizations_en.dart';

void main() {
  final l10n = AppLocalizationsEn();
  const repository = HomeRepositoryImpl();

  group('HomeRepositoryImpl', () {
    test('starterPath returns the four ordered steps', () {
      final steps = repository.starterPath(l10n);
      expect(
        steps.map((s) => s.route),
        [
          AppRoutes.reroll,
          AppRoutes.starterCarry,
          AppRoutes.shopPriority,
          AppRoutes.urPriority,
        ],
      );
      expect(steps.first.title, l10n.starterRerollTitle);
    });

    test('featuredHeroes returns four heroes with profile images', () {
      final heroes = repository.featuredHeroes(l10n);
      expect(heroes.map((h) => h.name), ['Renais', 'Adele', 'Ling', 'Jeanne']);
      expect(heroes.every((h) => h.image.endsWith('profile.png')), isTrue);
      expect(heroes.last.route, AppRoutes.jeanne);
    });

    test('guideSections returns six sections', () {
      final sections = repository.guideSections(l10n);
      expect(sections, hasLength(6));
      expect(sections.first.route, AppRoutes.gettingStarted);
    });
  });
}
