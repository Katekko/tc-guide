import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import '../entities/hero_item.dart';
import '../entities/link_item.dart';

/// Provides the content shown on the home screen.
///
/// The app has no backend, so the "data source" is the localized content in
/// [AppLocalizations]; each method maps the active locale's strings into pure
/// domain entities.
abstract class HomeRepository {
  /// Ordered steps of the recommended starter route.
  List<LinkItem> starterPath(AppLocalizations l10n);

  /// Heroes featured on the landing page.
  List<HeroItem> featuredHeroes(AppLocalizations l10n);

  /// Top-level guide sections.
  List<LinkItem> guideSections(AppLocalizations l10n);
}
