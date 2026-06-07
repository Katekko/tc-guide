import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tc_flutter_web/core/theme/app_colors.dart';
import 'package:tc_flutter_web/l10n/generated/app_localizations.dart';

import 'feedback_sheet.dart';

/// Persistent feedback entry point shown on every page.
///
/// Tapping it opens [FeedbackSheet], automatically attaching the current route
/// so a report is tied to the page the visitor was viewing.
class FeedbackFab extends StatelessWidget {
  /// Creates the feedback FAB.
  const FeedbackFab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final route = GoRouterState.of(context).matchedLocation;

    return FloatingActionButton.extended(
      onPressed: () => FeedbackSheet.show(context, pageRoute: route),
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
      tooltip: l10n.feedbackFabTooltip,
      icon: const Icon(Icons.feedback_outlined),
      label: Text(l10n.feedbackFabTooltip),
    );
  }
}
