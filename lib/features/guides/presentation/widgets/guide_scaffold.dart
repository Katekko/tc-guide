import 'package:flutter/material.dart';

import 'package:tc_flutter_web/core/di/injection_container.dart';
import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import '../../domain/repositories/guides_repository.dart';
import 'docs_mobile_index.dart';
import 'docs_sidebar.dart';
import 'guide_app_bar.dart';
import 'guide_header.dart';

/// The persistent shell for every guide page: app bar + responsive navigation
/// (sidebar on wide screens, chip strip on narrow ones) + a swappable content
/// slot.
///
/// Hosted once by the router's `ShellRoute`, so navigating between guides only
/// replaces [child]; the app bar and sidebar stay mounted and never re-animate.
class DocsScaffold extends StatelessWidget {
  /// Creates the docs shell for the page at [currentPath].
  const DocsScaffold({
    required this.currentPath,
    required this.child,
    super.key,
  });

  /// The active route, used to highlight navigation and resolve the title.
  final String currentPath;

  /// The swappable page body.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final repository = sl<GuidesRepository>();
    final entries = repository.navigation(l10n);
    final items = repository.flatItems(l10n);
    final title = repository.titleForRoute(l10n, currentPath);

    return Scaffold(
      appBar: GuideAppBar(title: title),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 900) {
            return Column(
              children: [
                DocsMobileIndex(items: items, currentPath: currentPath),
                Expanded(child: child),
              ],
            );
          }

          return Row(
            children: [
              DocsSidebar(entries: entries, currentPath: currentPath),
              Expanded(child: child),
            ],
          );
        },
      ),
    );
  }
}

/// The scrollable content of a single guide page: a [GuideHeader] followed by a
/// vertically spaced [GuideContent] column.
///
/// The surrounding chrome (app bar + sidebar) is provided once by [DocsScaffold]
/// via the router's `ShellRoute`, so navigating between guides only swaps this
/// content — the left panel stays fixed and never re-animates.
///
/// Each guide screen builds its structure once with these widgets and pulls
/// every string from [AppLocalizations].
class GuideScaffold extends StatelessWidget {
  /// Creates a guide page body.
  const GuideScaffold({
    required this.title,
    required this.children,
    this.eyebrow,
    this.intro,
    super.key,
  });

  /// Page title shown in the header.
  final String title;

  /// Content blocks rendered below the header.
  final List<Widget> children;

  /// Optional kicker above the title.
  final String? eyebrow;

  /// Optional intro paragraph below the title.
  final String? intro;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          GuideHeader(title: title, eyebrow: eyebrow, intro: intro),
          GuideContent(children: children),
        ],
      ),
    );
  }
}
