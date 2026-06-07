import 'package:flutter_test/flutter_test.dart';
import 'package:tc_flutter_web/features/guides/data/repositories/guides_repository_impl.dart';
import 'package:tc_flutter_web/features/guides/presentation/guide_screen_builders.dart';
import 'package:tc_flutter_web/l10n/generated/app_localizations_en.dart';

void main() {
  final l10n = AppLocalizationsEn();
  const repository = GuidesRepositoryImpl();

  group('guideScreenBuilders', () {
    test('every navigation route has exactly one screen builder', () {
      final navRoutes = repository.flatItems(l10n).map((i) => i.route).toSet();
      expect(guideScreenBuilders.keys.toSet(), navRoutes);
    });

    test('there are no duplicate builder routes', () {
      expect(
        guideScreenBuilders.keys.toSet(),
        hasLength(guideScreenBuilders.length),
      );
    });
  });
}
