import 'package:flutter_test/flutter_test.dart';
import 'package:tc_flutter_web/core/router/app_routes.dart';
import 'package:tc_flutter_web/features/guides/data/repositories/guides_repository_impl.dart';
import 'package:tc_flutter_web/features/guides/domain/entities/guide_nav.dart';
import 'package:tc_flutter_web/features/guides/domain/entities/guide_status.dart';
import 'package:tc_flutter_web/l10n/generated/app_localizations_en.dart';

void main() {
  final l10n = AppLocalizationsEn();
  const repository = GuidesRepositoryImpl();

  group('GuidesRepositoryImpl', () {
    test('navigation starts with the index link followed by seven sections',
        () {
      final nav = repository.navigation(l10n);
      expect(nav.first, isA<GuideNavLink>());
      expect((nav.first as GuideNavLink).route, AppRoutes.intro);
      expect(nav.whereType<GuideNavSection>(), hasLength(7));
    });

    test('flatItems contains all sixteen guide routes without duplicates', () {
      final routes = repository.flatItems(l10n).map((i) => i.route).toList();
      expect(routes, hasLength(16));
      expect(routes.toSet(), hasLength(16));
    });

    test('titleForRoute resolves a known route and falls back otherwise', () {
      expect(repository.titleForRoute(l10n, AppRoutes.reroll), l10n.navReroll);
      expect(repository.titleForRoute(l10n, '/docs/unknown'), '/docs/unknown');
    });

    test('startHere lists the four newcomer steps in order', () {
      final routes = repository.startHere(l10n).map((s) => s.route).toList();
      expect(routes, [
        AppRoutes.reroll,
        AppRoutes.starterCarry,
        AppRoutes.shopPriority,
        AppRoutes.urPriority,
      ]);
    });

    test('navigable items default to draft status', () {
      final statuses = repository.flatItems(l10n).map((i) => i.status).toSet();
      expect(statuses, {GuideStatus.draft});
    });
  });
}
