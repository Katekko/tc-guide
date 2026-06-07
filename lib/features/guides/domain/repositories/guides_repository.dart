import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import '../entities/guide_nav.dart';
import '../entities/guide_step.dart';

/// Exposes the guide navigation tree (sidebar structure + page titles).
///
/// Route paths are defined once in `AppRoutes`; this repository attaches the
/// localized labels for the active locale.
abstract class GuidesRepository {
  /// The ordered sidebar entries (a leading index link followed by sections).
  List<GuideNavEntry> navigation(AppLocalizations l10n);

  /// All navigable items flattened in display order (used by the mobile strip
  /// and title lookups).
  List<GuideNavItem> flatItems(AppLocalizations l10n);

  /// The page title for [route], or a fallback when unknown.
  String titleForRoute(AppLocalizations l10n, String route);

  /// The ordered "Start Here" steps a newcomer should follow on the index.
  List<GuideStep> startHere(AppLocalizations l10n);
}
